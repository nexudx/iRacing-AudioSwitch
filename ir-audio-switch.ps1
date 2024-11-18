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
        $logContent = Get-Content -Path $logFilePath -Tail $maxLines
        Set-Content -Path $logFilePath -Value $logContent
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
        [string]$defaultMic,      # Neu hinzugefügt
        [string]$vrMic,           # Neu hinzugefügt
        [int]$maxLines = $MaxLogLines
    )
    @{ 
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice 
        defaultMic = $defaultMic      # Neu hinzugefügt
        vrMic = $vrMic                # Neu hinzugefügt
        maxLogLines = $maxLines
    } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
    Write-Log "Configuration saved with MaxLogLines: $maxLines"
}

function Initialize-DeviceConfiguration {
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
    $mics = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Recording' }
    
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
    
    Write-Host ""
    Write-Host "Available Recording Devices:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    for ($i = 0; $i -lt $mics.Count; $i++) {
        $isDefault = if ($mics[$i].Default) { "(Default)" } else { "" }
        Write-Host ("[{0}] {1} {2}" -f $i, $mics[$i].Name, $isDefault)
    }

    # Auswahl des Standardmikrofons
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

    # Auswahl des VR-Mikrofons
    do {
        Write-Host "Select VR microphone number [0-$($mics.Count - 1)]: " -NoNewline
        $vrMicSelection = Read-Host
        if ($vrMicSelection -match '^\d+$' -and [int]$vrSelection -ge 0 -and [int]$vrMicSelection -lt $mics.Count) {
            $vrMic = $mics[[int]$vrMicSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $vrMic)
    Write-Log "Selected VR microphone: $vrMic"

    Save-Configuration -defaultDevice $defaultDevice -vrDevice $vrDevice -defaultMic $defaultMic -vrMic $vrMic
    return @{
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice
        defaultMic = $defaultMic      # Neu hinzugefügt
        vrMic = $vrMic                # Neu hinzugefügt
    }
}

function Set-DefaultAudioDevice {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$deviceName,
        [Parameter(Mandatory)][string]$micName,    # Neu hinzugefügt
        [int]$retryCount = 2,
        [int]$retryDelay = 1000
    )
    
    $success = $true  # Variable zur Überprüfung, ob alle Wechsel erfolgreich waren

    # Umschalten des Wiedergabegeräts
    $currentDefault = Get-AudioDevice -Playback
    if ($currentDefault.Name -ne $deviceName) {
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
                    break
                }
            } catch {
                Write-Log "Switch failed: $_ (Attempt $i/$retryCount)" -Level Warning
                Start-Sleep -Milliseconds $retryDelay
            }
        }

        # Überprüfen, ob der Wechsel erfolgreich war
        if ((Get-AudioDevice -Playback).Name -ne $deviceName) {
            Write-Log "Failed to switch playback device to: $deviceName" -Level Error
            $success = $false
        }
    } else {
        Write-Log "Audio device '$deviceName' already active" -Level Debug
    }

    # Umschalten des Aufnahmegeräts
    $currentDefaultMic = Get-AudioDevice -Recording
    if ($currentDefaultMic.Name -ne $micName) {
        for ($i = 1; $i -le $retryCount; $i++) {
            try {
                $micDevice = Get-AudioDevice -List |
                    Where-Object { $_.Name -eq $micName -and $_.Type -eq 'Recording' } |
                    Select-Object -First 1

                if (-not $micDevice) {
                    Write-Log "Microphone not found: $micName (Attempt $i/$retryCount)" -Level Warning
                    continue
                }

                Set-AudioDevice -ID $micDevice.ID
                Start-Sleep -Milliseconds 250

                if ((Get-AudioDevice -Recording).Name -eq $micName) {
                    Write-Log "Switched microphone to: $micName"
                    break
                }
            } catch {
                Write-Log "Microphone switch failed: $_ (Attempt $i/$retryCount)" -Level Warning
                Start-Sleep -Milliseconds $retryDelay
            }
        }

        # Überprüfen, ob der Wechsel erfolgreich war
        if ((Get-AudioDevice -Recording).Name -ne $micName) {
            Write-Log "Failed to switch microphone to: $micName" -Level Error
            $success = $false
        }
    } else {
        Write-Log "Microphone '$micName' already active" -Level Debug
    }

    return $success
}

function Invoke-Cleanup {
    param(
        [string]$DefaultDevice,
        [string]$DefaultMic    # Neu hinzugefügt
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
        [Parameter(Mandatory)][string]$DefaultMic,   # Neu hinzugefügt
        [Parameter(Mandatory)][string]$VRMic         # Neu hinzugefügt
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
                if ($currentState) {
                    $targetDevice = $VRDevice
                    $targetMic = $VRMic             # Neu hinzugefügt
                } else {
                    $targetDevice = $DefaultDevice
                    $targetMic = $DefaultMic        # Neu hinzugefügt
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
            
            Start-Sleep -Milliseconds 250
        }
    } catch {
        Write-Log "Critical error: $_" -Level Error
        throw
    } finally {
        Get-EventSubscriber | Unregister-Event
        Invoke-Cleanup -DefaultDevice $DefaultDevice -DefaultMic $DefaultMic   # Geändert
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
    Write-Log "Default microphone: $($config.defaultMic)"    # Neu hinzugefügt
    Write-Log "VR microphone: $($config.vrMic)"              # Neu hinzugefügt
    Watch-IRacingProcess -DefaultDevice $config.defaultDevice -VRDevice $config.vrDevice -DefaultMic $config.defaultMic -VRMic $config.vrMic
} catch {
    Write-Log "Critical error: $_" -Level Error
    if ($null -ne $config -and $null -ne $config.defaultDevice -and $null -ne $config.defaultMic) {
        Invoke-Cleanup -DefaultDevice $config.defaultDevice -DefaultMic $config.defaultMic   # Geändert
    }
    exit 1
}
