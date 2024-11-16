[CmdletBinding()]
param(
    [ValidateScript({
        $parent = Split-Path $_ -Parent
        if (-not (Test-Path $parent)) {
            throw "Folder does not exist: $parent"
        }
        return $true
    })]
    [string]$LogFile = "$(Join-Path $PSScriptRoot 'ir-audio-switch.log')",
    
    [ValidateRange(10, 10000)]
    [int]$MaxLogLines = 42
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:configPath = Join-Path $PSScriptRoot "ir-audio-switch.cfg.json"
$script:exitRequested = $false
$script:audioDeviceCache = @{}

function Update-Log {
    param (
        [string]$logFilePath,
        [int]$maxLines
    )
    if (Test-Path $logFilePath) {
        $logContent = @(Get-Content $logFilePath)
        if ($logContent.Count -gt $maxLines) {
            $trimmedContent = $logContent[-$maxLines..-1]
            Set-Content -Path $logFilePath -Value $trimmedContent
        }
    }
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error','Debug')][string]$Level = 'Info',
        [string]$ScriptBlock = $MyInvocation.ScriptLineNumber
    )
    try {
        Update-Log -logFilePath $LogFile -maxLines $MaxLogLines
        $timestamp = Get-Date -Format "HH:mm:ss"
        $logMessage = "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] [$Level] [$ScriptBlock] $Message"
        
        $consoleMessage = "[{0}] [{1,-7}] {2}" -f $timestamp, $Level, $Message
        
        $LevelColors = @{
            'Info'    = 'White'
            'Warning' = 'Yellow'
            'Error'   = 'Red'
            'Debug'   = 'Gray'
        }
        $color = $LevelColors[$Level]
        
        if ($Level -eq 'Debug' -and $VerbosePreference -ne 'Continue') {
            # Do not output Debug messages if VerbosePreference is not 'Continue'
        } else {
            Write-Host $consoleMessage -ForegroundColor $color
        }
        
        Add-Content -Path $LogFile -Value $logMessage
    } catch {
        Write-Host "Failed to write log: $_" -ForegroundColor Red
    }
}

function Test-AudioDeviceExists {
    [OutputType([bool])]
    param ([string]$deviceName)
    
    if ($script:audioDeviceCache.ContainsKey($deviceName)) {
        return $script:audioDeviceCache[$deviceName]
    }
    
    $exists = [bool](Get-AudioDevice -List | Where-Object { $_.Name -eq $deviceName })
    $script:audioDeviceCache[$deviceName] = $exists
    return $exists
}

function Get-SavedConfiguration {
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            
            if ($config.maxLogLines) {
                $script:MaxLogLines = $config.maxLogLines
            }
            
            $defaultDeviceExists = Test-AudioDeviceExists $config.defaultDevice
            $vrDeviceExists = Test-AudioDeviceExists $config.vrDevice
            
            if (-not $defaultDeviceExists) {
                Write-Log "Default device '$($config.defaultDevice)' not found!" -Level Error
            }
            if (-not $vrDeviceExists) {
                Write-Log "VR device '$($config.vrDevice)' not found!" -Level Error
            }
            
            if ($defaultDeviceExists -and $vrDeviceExists) {
                Write-Log "Configuration loaded successfully"
                return $config
            }
            Write-Log "Starting device selection..." -Level Warning
        } catch {
            Write-Log "Error loading configuration: $_" -Level Error
        }
    }
    return $null
}

function Save-Configuration {
    param (
        [string]$defaultDevice, 
        [string]$vrDevice,
        [int]$maxLines = $MaxLogLines
    )
    @{ 
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice 
        maxLogLines = $maxLines
    } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
    Write-Log "Configuration saved with MaxLogLines: $maxLines"
}

function Initialize-DeviceConfiguration {
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
    
    Write-Log "Starting initial device configuration..."
    Write-Host ""
    Write-Host "Available Playback Devices:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $isDefault = if ($devices[$i].Default) { "(Default)" } else { "" }
        Write-Host ("[{0}] {1} {2}" -f $i, $devices[$i].Name, $isDefault)
    }
    
    Write-Host ""
    
    do {
        Write-Host "Select default device number [0-$($devices.Count - 1)]: " -NoNewline
        $defaultSelection = Read-Host
        if ($defaultSelection -match '^\d+$' -and [int]$defaultSelection -ge 0 -and [int]$defaultSelection -lt $devices.Count) {
            $defaultDevice = $devices[[int]$defaultSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $defaultDevice)
    Write-Log "Selected default device: $defaultDevice"
    
    do {
        Write-Host "Select VR device number [0-$($devices.Count - 1)]: " -NoNewline
        $vrSelection = Read-Host
        if ($vrSelection -match '^\d+$' -and [int]$vrSelection -ge 0 -and [int]$vrSelection -lt $devices.Count) {
            $vrDevice = $devices[[int]$vrSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $vrDevice)
    Write-Log "Selected VR device: $vrDevice"
    
    Save-Configuration -defaultDevice $defaultDevice -vrDevice $vrDevice
    return @{
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice
    }
}

function Set-DefaultAudioDevice {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$deviceName,
        [int]$retryCount = 2,
        [int]$retryDelay = 1000
    )
    
    $currentDefault = Get-AudioDevice -Playback
    if ($currentDefault.Name -eq $deviceName) {
        Write-Log "Audio device '$deviceName' already active" -Level Debug
        return $true
    }
    
    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            $audioDevice = Get-AudioDevice -List | 
                Where-Object { $_.Name -eq $deviceName -and $_.Type -eq 'Playback' } |
                Select-Object -First 1
                
            if (-not $audioDevice) {
                Write-Log "Device not found: $deviceName (Attempt $i/$retryCount)" -Level Warning
                continue
            }
            
            Set-AudioDevice -ID $audioDevice.ID
            Start-Sleep -Milliseconds 250
            
            if ((Get-AudioDevice -Playback).Name -eq $deviceName) {
                Write-Log "Switched to: $deviceName"
                return $true
            }
        } catch {
            Write-Log "Switch failed: $_ (Attempt $i/$retryCount)" -Level Warning
            Start-Sleep -Milliseconds $retryDelay
        }
    }
    return $false
}

function Invoke-Cleanup {
    param(
        [string]$DefaultDevice
    )
    Write-Log "Shutting down Audio Switcher..."
    
    if (-not (Set-DefaultAudioDevice $DefaultDevice)) {
        Write-Log "Failed to restore default audio device!" -Level Error
    }
    
    Write-Log "Cleanup completed"
}

function Watch-IRacingProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DefaultDevice,
        [Parameter(Mandatory)][string]$VRDevice
    )
    
    try {
        $null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
            $script:exitRequested = $true
            $event.Cancel = $true
        }
        
        $processName = "iRacingSim64DX11"
        $switchAttempts = 0
        $lastState = $false
        
        while (-not $script:exitRequested) {
            $currentState = [bool](Get-Process -Name $processName -ErrorAction SilentlyContinue)
            
            if ($currentState -ne $lastState) {
                $targetDevice = if ($currentState) { $VRDevice } else { $DefaultDevice }
                
                if (-not (Set-DefaultAudioDevice $targetDevice)) {
                    $switchAttempts++ 
                    if ($switchAttempts -gt 3) {
                        throw "Multiple device switch failures"
                    }
                    Start-Sleep -Seconds 1
                    continue
                }
                
                $switchAttempts = 0
                $lastState = $currentState
                
                if ($currentState) {
                    Write-Log "Switched to VR device: $VRDevice"
                } else {
                    Write-Log "Switched to default device: $DefaultDevice"
                }
            }
            
            Start-Sleep -Milliseconds 250
        }
    } catch {
        Write-Log "Critical error: $_" -Level Error
        throw
    } finally {
        Get-EventSubscriber | Unregister-Event
        Invoke-Cleanup -DefaultDevice $DefaultDevice
    }
}

try {
    if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
        Write-Log "Installing AudioDeviceCmdlets module..." -Level Warning
        Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
    }
    Import-Module AudioDeviceCmdlets

    $config = Get-SavedConfiguration
    if ($null -eq $config) {
        $config = Initialize-DeviceConfiguration
    }
    
    Write-Log "Starting with configuration:"
    Write-Log "Default device: $($config.defaultDevice)"
    Write-Log "VR device: $($config.vrDevice)"
    Watch-IRacingProcess -DefaultDevice $config.defaultDevice -VRDevice $config.vrDevice
} catch {
    Write-Log "Critical error: $_" -Level Error
    if ($null -ne $config -and $null -ne $config.defaultDevice) {
        Invoke-Cleanup -DefaultDevice $config.defaultDevice
    }
    exit 1
}
