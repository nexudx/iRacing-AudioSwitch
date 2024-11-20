<#
.SYNOPSIS
    Switches audio output and input devices based on whether iRacing is running.

.DESCRIPTION
    This script monitors the iRacing process and automatically switches between default and VR audio devices 
    when iRacing starts or stops. It also handles microphone switching and provides persistent configuration, 
    detailed logging, and robust error handling.

.PARAMETER LogFile
    Path to the log file. Defaults to 'ir-audio-switch.log' in the script directory.

.PARAMETER MaxLogLines
    Maximum number of lines to keep in the log file. Defaults to 42. Valid range is 10-10000.

.EXAMPLE
    .\ir-audio-switch.ps1
    Starts the script with default settings.

.EXAMPLE
    .\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
    Starts the script with a custom log file path and maximum log lines.

.NOTES
    Requires the AudioDeviceCmdlets module. It will be installed automatically if not present.
    Requires administrator rights for the initial installation of the module.
#>
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

Set-StrictMode -Version 5.1
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:configPath = Join-Path $PSScriptRoot "ir-audio-switch.cfg.json"
$script:exitRequested = $false
$script:audioDeviceCache = @{}

<#
.SYNOPSIS
    Updates the log file, keeping only the last specified lines.

.DESCRIPTION
    This function reads the log file, extracts the last 'maxLines' lines, and overwrites the file with the extracted content.

.PARAMETER logFilePath
    The path to the log file.

.PARAMETER maxLines
    The maximum number of lines to keep in the log file.
#>
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

<#
.SYNOPSIS
    Writes a message to the log file and console.

.DESCRIPTION
    This function formats and writes a log message to the specified log file and displays it in the console with appropriate color coding.

.PARAMETER Message
    The message to log.

.PARAMETER Level
    The log level ('Info', 'Warning', 'Error', 'Debug'). Defaults to 'Info'.

.PARAMETER ScriptBlock
    The line number of the calling script block. Used for debugging.
#>
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
            return
        }
        
        Write-Host $consoleMessage -ForegroundColor $color
        Add-Content -Path $LogFile -Value $logMessage
    } catch {
        Write-Host "Failed to write log: $_" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
    Checks if an audio device exists.

.DESCRIPTION
    This function checks if a given audio device exists and caches the result to avoid redundant lookups.

.PARAMETER deviceName
    The name of the audio device to check.

.OUTPUTS
    [bool] True if the device exists, False otherwise.
#>
function Test-AudioDeviceExists {
    [OutputType([bool])]
    param ([string]$deviceName)
    
    if ($script:audioDeviceCache.ContainsKey($deviceName)) {
        return $script:audioDeviceCache[$deviceName]
    }
    
    $device = Get-AudioDevice -List | Where-Object { $_.Name -eq $deviceName }
    $exists = [bool]$device
    $script:audioDeviceCache[$deviceName] = $device # Cache the device object
    return $exists
}

<#
.SYNOPSIS
    Retrieves saved audio device configuration.

.DESCRIPTION
    This function loads and validates the saved audio device configuration from a JSON file.

.OUTPUTS
    [hashtable] The configuration hashtable, or $null if loading or validation fails.
#>
function Get-SavedConfiguration {
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            
            if ($config.maxLogLines) {
                $script:MaxLogLines = $config.maxLogLines
            }
            
            $defaultDevice = Test-AudioDeviceExists $config.defaultDevice
            $vrDevice = Test-AudioDeviceExists $config.vrDevice
            
            if (-not $defaultDevice) {
                Write-Log "Default device '$($config.defaultDevice)' not found!" -Level Error
            }
            if (-not $vrDevice) {
                Write-Log "VR device '$($config.vrDevice)' not found!" -Level Error
            }
            
            if ($defaultDevice -and $vrDevice) {
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

<#
.SYNOPSIS
    Saves the audio device configuration.

.DESCRIPTION
    This function saves the specified audio device configuration to a JSON file.

.PARAMETER defaultDevice
    The name of the default audio device.

.PARAMETER vrDevice
    The name of the VR audio device.

.PARAMETER defaultMic
    The name of the default microphone.

.PARAMETER vrMic
    The name of the VR microphone.

.PARAMETER maxLines
    The maximum number of lines to keep in the log file. Defaults to the current value of $MaxLogLines.
#>
function Save-Configuration {
    param (
        [string]$defaultDevice, 
        [string]$vrDevice,
        [string]$defaultMic,
        [string]$vrMic,
        [int]$maxLines = $MaxLogLines
    )
    @{ 
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice 
        defaultMic = $defaultMic
        vrMic = $vrMic
        maxLogLines = $maxLines
    } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
    Write-Log "Configuration saved with MaxLogLines: $maxLines"
}


<#
.SYNOPSIS
    Initializes the audio device configuration.

.DESCRIPTION
    This function prompts the user to select default and VR audio devices and microphones, and saves the configuration.

.OUTPUTS
    [hashtable] The initialized configuration hashtable.
#>
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

    Save-Configuration -defaultDevice $defaultDevice -vrDevice $vrDevice -defaultMic $defaultMic -vrMic $vrMic
    return @{
        defaultDevice = $defaultDevice
        vrDevice = $vrDevice
        defaultMic = $defaultMic
        vrMic = $vrMic
    }
}

<#
.SYNOPSIS
    Sets the default audio device.

.DESCRIPTION
    Sets the default audio playback and recording devices.  Includes retry logic to handle temporary device unavailability.

.PARAMETER deviceName
    The name of the audio playback device to set as default.

.PARAMETER micName
    The name of the audio recording device to set as default.

.PARAMETER retryCount
    The number of times to retry setting the device.  Defaults to 2.

.PARAMETER retryDelay
    The delay in milliseconds between retry attempts. Defaults to 1000.

.OUTPUTS
    [bool] True if the device was set successfully, False otherwise.
#>
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
                    $audioDevice = Test-AudioDeviceExists $deviceName # Use cached device object if available
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
                    $micDevice = Test-AudioDeviceExists $micName # Use cached device object if available
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

<#
.SYNOPSIS
    Performs cleanup actions before script exit.

.DESCRIPTION
    Restores the default audio devices and logs the cleanup process.

.PARAMETER DefaultDevice
    The name of the default playback device.

.PARAMETER DefaultMic
    The name of the default recording device.
#>
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

<#
.SYNOPSIS
    Watches the iRacing process and switches audio devices.

.DESCRIPTION
    Monitors the iRacing process and switches between default and VR audio devices when iRacing starts or stops.

.PARAMETER DefaultDevice
    The name of the default playback device.

.PARAMETER VRDevice
    The name of the VR playback device.

.PARAMETER DefaultMic
    The name of the default recording device.

.PARAMETER VRMic
    The name of the VR recording device.
#>
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
        
        $processName = "iRacingSim64DX11"
        $switchAttempts = 0
        $lastState = $false
        
        while (-not $script:exitRequested) {
            $currentState = [bool](Get-Process -Name $processName -ErrorAction SilentlyContinue)
            
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
            
            Start-Sleep -Milliseconds 250
        }
    } catch {
        Write-Log "Critical error: $_" -Level Error
        throw
    } finally {
        Get-EventSubscriber | Unregister-Event
        Invoke-Cleanup -DefaultDevice $DefaultDevice -DefaultMic $DefaultMic
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
    Write-Log "Default microphone: $($config.defaultMic)"
    Write-Log "VR microphone: $($config.vrMic)"
    Watch-IRacingProcess -DefaultDevice $config.defaultDevice -VRDevice $config.vrDevice -DefaultMic $config.defaultMic -VRMic $config.vrMic
} catch {
    Write-Log "Critical error: $_" -Level Error
    if ($null -ne $config -and $null -ne $config.defaultDevice -and $null -ne $config.defaultMic) {
        Invoke-Cleanup -DefaultDevice $config.defaultDevice -DefaultMic $config.defaultMic
    }
    exit 1
}
