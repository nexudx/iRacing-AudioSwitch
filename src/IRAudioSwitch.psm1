using namespace System.Collections.Generic

#Region Classes
class ProcessMonitor {
    [string]$ProcessName
    [int]$PollInterval
    [bool]$IsRunning

    ProcessMonitor() {
        $this.ProcessName = "iRacingSim64DX11"
        $this.PollInterval = 500  # Increased from 250ms to 500ms for better performance
        $this.IsRunning = $false
    }
    
    ProcessMonitor([string]$name) {
        $this.ProcessName = $name
        $this.PollInterval = 500  # Increased from 250ms to 500ms for better performance
        $this.IsRunning = $false
    }
    
    ProcessMonitor([string]$name, [int]$interval) {
        $this.ProcessName = $name
        $this.PollInterval = $interval
        $this.IsRunning = $false
    }
    
    [bool] CheckProcess() {
        $this.IsRunning = [bool](Get-Process -Name $this.ProcessName -ErrorAction SilentlyContinue)
        return $this.IsRunning
    }
}

class AudioDeviceManager {
    hidden [hashtable]$DeviceCache
    [string]$DefaultDevice
    [string]$VRDevice
    [string]$DefaultMic
    [string]$VRMic

    AudioDeviceManager() {
        $this.DeviceCache = @{}
    }

    AudioDeviceManager([string]$defaultDevice, [string]$vrDevice, [string]$defaultMic, [string]$vrMic) {
        $this.DeviceCache = @{}
        $this.DefaultDevice = $defaultDevice
        $this.VRDevice = $vrDevice
        $this.DefaultMic = $defaultMic
        $this.VRMic = $vrMic
        $this.RefreshDeviceCache()
    }

    [void] RefreshDeviceCache() {
        $devices = Get-AudioDevice -List
        $this.DeviceCache.Clear()
        foreach ($device in $devices) {
            $this.DeviceCache[$device.Name] = $device
        }
    }

    [bool] DeviceExists([string]$deviceName) {
        if (-not $this.DeviceCache.ContainsKey($deviceName)) {
            $this.RefreshDeviceCache()
        }
        return $this.DeviceCache.ContainsKey($deviceName)
    }

    [hashtable] GetDeviceHealth() {
        $results = @{}
        foreach ($device in @($this.DefaultDevice, $this.VRDevice, $this.DefaultMic, $this.VRMic)) {
            $exists = $this.DeviceExists($device)
            $results[$device] = @{
                Status = if ($exists) { "OK" } else { "Missing" }
                LastChecked = Get-Date
            }
        }
        return $results
    }

    [object] GetCachedDevice([string]$deviceName) {
        if ($this.DeviceExists($deviceName)) {
            return $this.DeviceCache[$deviceName]
        }
        return $null
    }
}
#EndRegion Classes

#Region Script Variables
$script:configPath = Join-Path $PSScriptRoot "IRAudioSwitch.cfg.json"
$script:exitRequested = $false
$script:LogFile = Join-Path $PSScriptRoot "IRAudioSwitch.log"
$script:MaxLogLines = 42
$script:LogLevel = 'Info'
$script:AudioManager = $null
$script:LogLevels = @{
    'Error' = 0
    'Warning' = 1
    'Info' = 2
    'Debug' = 3
}
#EndRegion Script Variables

#Region Helper Functions
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error','Debug')][string]$Level = 'Info',
        [string]$ScriptBlock = $MyInvocation.ScriptLineNumber
    )
    
    if ($script:LogLevels[$Level] -le $script:LogLevels[$script:LogLevel]) {
        try {
            $timestamp = Get-Date -Format "HH:mm:ss"
            $logMessage = "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] [$Level] [$ScriptBlock] $Message"
            
            $consoleMessage = "[{0}] [{1,-7}] {2}" -f $timestamp, $Level, $Message
            
            $LevelColors = @{
                'Info'    = 'White'
                'Warning' = 'Yellow'
                'Error'   = 'Red'
                'Debug'   = 'Gray'
            }
            
            Write-Host $consoleMessage -ForegroundColor $LevelColors[$Level]
            Add-Content -Path $script:LogFile -Value $logMessage
        } catch {
            Write-Host "Failed to write log: $_" -ForegroundColor Red
        }
    }
}

function Update-Log {
    param (
        [string]$logFilePath,
        [int]$maxLines
    )
    if (Test-Path $logFilePath) {
        $logContent = Get-Content -Path $logFilePath -Tail $maxLines
        Set-Content -Path $logFilePath -Value $logContent
    }
}

function Test-Configuration {
    param (
        [Parameter(Mandatory)][hashtable]$Config
    )
    
    $requiredKeys = @('defaultDevice', 'vrDevice', 'defaultMic', 'vrMic')
    $missingKeys = $requiredKeys | Where-Object { -not $Config.ContainsKey($_) }
    
    if ($missingKeys) {
        throw "Missing required configuration keys: $($missingKeys -join ', ')"
    }

    $script:AudioManager = [AudioDeviceManager]::new(
        $Config.defaultDevice,
        $Config.vrDevice,
        $Config.defaultMic,
        $Config.vrMic
    )

    $health = $script:AudioManager.GetDeviceHealth()
    $missingDevices = $health.Keys | Where-Object { $health[$_].Status -eq "Missing" }
    
    if ($missingDevices) {
        throw "Missing audio devices: $($missingDevices -join ', ')"
    }
}

function Save-AudioProfile {
    param (
        [Parameter(Mandatory)][string]$ProfileName,
        [Parameter(Mandatory)][hashtable]$Config
    )
    
    $profilePath = Join-Path $PSScriptRoot "profiles/$ProfileName.json"
    Test-Configuration -Config $Config
    $Config | ConvertTo-Json | Set-Content -Path $profilePath -Encoding UTF8
    Write-Log "Saved audio profile: $ProfileName"
}

function Get-AudioProfile {
    param (
        [Parameter(Mandatory)][string]$ProfileName
    )
    
    $profilePath = Join-Path $PSScriptRoot "profiles/$ProfileName.json"
    if (-not (Test-Path $profilePath)) {
        throw "Profile not found: $ProfileName"
    }
    
    $config = Get-Content -Path $profilePath -Raw | ConvertFrom-Json -AsHashtable
    Test-Configuration -Config $config
    return $config
}

function Set-DefaultAudioDevice {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$deviceName,
        [Parameter(Mandatory)][string]$micName,
        [int]$retryCount = 2,
        [int]$retryDelay = 1000
    )
    
    $success = $true
    $deviceSet = $false
    $micSet = $false

    for ($i = 1; $i -le $retryCount; $i++) {
        if (-not $deviceSet) {
            try {
                $currentDefault = Get-AudioDevice -Playback
                if ($currentDefault.Name -ne $deviceName) {
                    $audioDevice = $script:AudioManager.GetCachedDevice($deviceName)
                    if (-not $audioDevice) {
                        Write-Log "Device not found: $deviceName (Attempt $i/$retryCount)" -Level Warning
                        continue
                    }
                    Set-AudioDevice -ID $audioDevice.ID
                    Start-Sleep -Milliseconds 250

                    if ((Get-AudioDevice -Playback).Name -eq $deviceName) {
                        Write-Log "Switched to: $deviceName"
                        $deviceSet = $true
                    }
                }
                else {
                    Write-Log "Audio device '$deviceName' already active" -Level Debug
                    $deviceSet = $true
                }
            }
            catch {
                Write-Log "Switch failed: $_ (Attempt $i/$retryCount)" -Level Warning
                Start-Sleep -Milliseconds $retryDelay
            }
        }

        if (-not $micSet) {
            try {
                $currentDefaultMic = Get-AudioDevice -Recording
                if ($currentDefaultMic.Name -ne $micName) {
                    $micDevice = $script:AudioManager.GetCachedDevice($micName)
                    if (-not $micDevice) {
                        Write-Log "Microphone not found: $micName (Attempt $i/$retryCount)" -Level Warning
                        continue
                    }
                    Set-AudioDevice -ID $micDevice.ID
                    Start-Sleep -Milliseconds 250

                    if ((Get-AudioDevice -Recording).Name -eq $micName) {
                        Write-Log "Switched microphone to: $micName"
                        $micSet = $true
                    }
                } else {
                    Write-Log "Microphone '$micName' already active" -Level Debug
                    $micSet = $true
                }
            }
            catch {
                Write-Log "Microphone switch failed: $_ (Attempt $i/$retryCount)" -Level Warning
                Start-Sleep -Milliseconds $retryDelay
            }
        }

        if ($deviceSet -and $micSet) {
            break
        }
    }

    if (-not $deviceSet) {
        Write-Log "Failed to switch playback device to: $deviceName" -Level Error
        $success = $false
    }

    if (-not $micSet) {
        Write-Log "Failed to switch microphone to: $micName" -Level Error
        $success = $false
    }

    return $success
}
#EndRegion Helper Functions

#Region Main Functions
function Initialize-DeviceConfiguration {
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
    $mics = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Recording' }
    
    Write-Log "Starting initial device configuration..."
    Write-Host ""
    Write-Host "Available Playback Devices:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $deviceName = "[{0}] {1}" -f $i, $devices[$i].Name
        Write-Host $deviceName -NoNewline
        if ($devices[$i].Default) {
            Write-Host " (Default)" -ForegroundColor Cyan
        } else {
            Write-Host ""
        }
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
    
    Write-Host ""
    Write-Host "Available Recording Devices:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    for ($i = 0; $i -lt $mics.Count; $i++) {
        $micName = "[{0}] {1}" -f $i, $mics[$i].Name
        Write-Host $micName -NoNewline
        if ($mics[$i].Default) {
            Write-Host " (Default)" -ForegroundColor Cyan
        } else {
            Write-Host ""
        }
    }

    do {
        Write-Host "Select default microphone number [0-$($mics.Count - 1)]: " -NoNewline
        $defaultMicSelection = Read-Host
        if ($defaultMicSelection -match '^\d+$' -and [int]$defaultMicSelection -ge 0 -and [int]$defaultMicSelection -lt $mics.Count) {
            $defaultMic = $mics[[int]$defaultMicSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $defaultMic)
    Write-Log "Selected default microphone: $defaultMic"

    do {
        Write-Host "Select VR microphone number [0-$($mics.Count - 1)]: " -NoNewline
        $vrMicSelection = Read-Host
        if ($vrMicSelection -match '^\d+$' -and [int]$vrMicSelection -ge 0 -and [int]$vrMicSelection -lt $mics.Count) {
            $vrMic = $mics[[int]$vrMicSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $vrMic)
    Write-Log "Selected VR microphone: $vrMic"

    $config = @{
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice
        defaultMic = $defaultMic
        vrMic = $vrMic
        maxLogLines = $script:MaxLogLines
    }

    Save-Configuration @config
    return $config
}

function Save-Configuration {
    param (
        [string]$defaultDevice, 
        [string]$vrDevice,
        [string]$defaultMic,
        [string]$vrMic,
        [int]$maxLines = $script:MaxLogLines
    )
    @{ 
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice 
        defaultMic = $defaultMic
        vrMic = $vrMic
        maxLogLines = $maxLines
    } | ConvertTo-Json | Set-Content -Path $script:configPath -Encoding UTF8
    Write-Log "Configuration saved with MaxLogLines: $maxLines"
}

function Get-SavedConfiguration {
    if (Test-Path $script:configPath) {
        try {
            $config = Get-Content $script:configPath -Raw | ConvertFrom-Json -AsHashtable
            
            if ($config.maxLogLines) {
                $script:MaxLogLines = $config.maxLogLines
            }
            
            Test-Configuration -Config $config
            Write-Log "Configuration loaded successfully"
            return $config
        } catch {
            Write-Log "Error loading configuration: $_" -Level Error
        }
    }
    return $null
}

function Invoke-Cleanup {
    param(
        [string]$DefaultDevice,
        [string]$DefaultMic
    )
    Write-Log "Shutting down Audio Switcher..."
    
    if (-not (Set-DefaultAudioDevice -deviceName $DefaultDevice -micName $DefaultMic)) {
        Write-Log "Failed to restore default audio device!" -Level Error
    }
    
    Write-Log "Cleanup completed"
}

function Watch-IRacingProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DefaultDevice,
        [Parameter(Mandatory)][string]$VRDevice,
        [Parameter(Mandatory)][string]$DefaultMic,
        [Parameter(Mandatory)][string]$VRMic
    )
    
    try {
        $null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
            $script:exitRequested = $true
            $event.Cancel = $true
        }
        
        $monitor = [ProcessMonitor]::new()
        $switchAttempts = 0
        $lastState = $false
        
        while (-not $script:exitRequested) {
            $currentState = $monitor.CheckProcess()
            
            if ($currentState -ne $lastState) {
                if ($currentState) {
                    $targetDevice = $VRDevice
                    $targetMic = $VRMic
                } else {
                    $targetDevice = $DefaultDevice
                    $targetMic = $DefaultMic
                }

                if (-not (Set-DefaultAudioDevice -deviceName $targetDevice -micName $targetMic)) {
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
            
            Start-Sleep -Milliseconds $monitor.PollInterval
        }
    } catch {
        Write-Log "Critical error: $_" -Level Error
        throw
    } finally {
        Get-EventSubscriber | Unregister-Event
        Invoke-Cleanup -DefaultDevice $DefaultDevice -DefaultMic $DefaultMic
    }
}

function Start-AudioSwitcher {
    [CmdletBinding()]
    param(
        [ValidateScript({
            $parent = Split-Path $_ -Parent
            if (-not (Test-Path $parent)) {
                throw "Folder does not exist: $parent"
            }
            return $true
        })]
        [string]$LogFile = $script:LogFile,
        
        [ValidateRange(10, 10000)]
        [int]$MaxLogLines = $script:MaxLogLines,

        [ValidateSet('Error', 'Warning', 'Info', 'Debug')]
        [string]$LogLevel = 'Info',

        [string]$ProfileName
    )

    Set-StrictMode -Version 5.1
    $ErrorActionPreference = "Stop"
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $script:LogFile = $LogFile
    $script:MaxLogLines = $MaxLogLines
    $script:LogLevel = $LogLevel

    try {
        if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
            Write-Log "Installing AudioDeviceCmdlets module..." -Level Warning
            Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
        }
        Import-Module AudioDeviceCmdlets

        $config = if ($ProfileName) {
            Get-AudioProfile -ProfileName $ProfileName
        } else {
            $savedConfig = Get-SavedConfiguration
            if ($null -eq $savedConfig) {
                Initialize-DeviceConfiguration
            } else {
                $savedConfig
            }
        }
        
        Write-Log "Starting with configuration:"
        Write-Log "Default device: $($config.defaultDevice)"
        Write-Log "VR device: $($config.vrDevice)"
        Write-Log "Default microphone: $($config.defaultMic)"
        Write-Log "VR microphone: $($config.vrMic)"
        Watch-IRacingProcess -DefaultDevice $config.defaultDevice -VRDevice $config.vrDevice -DefaultMic $config.defaultMic -VRMic $config.vrMic
    } catch {
        Write-Log "Critical error: $_" -Level Error
        if ($null -ne $config -and $null -ne $config.defaultDevice -and $null -ne $config.defaultMic) {
            Invoke-Cleanup -DefaultDevice $config.defaultDevice -DefaultMic $config.defaultMic
        }
        throw
    }
}
#EndRegion Main Functions

# Export functions
Export-ModuleMember -Function Start-AudioSwitcher, Save-AudioProfile, Get-AudioProfile
