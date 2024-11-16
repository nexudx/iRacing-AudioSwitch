<#
.SYNOPSIS
    Automatically switches audio output devices when iRacing is launched or closed.

.DESCRIPTION
    This script monitors the iRacing process and automatically switches between two configured audio devices:
    - A default audio device for normal system use
    - A VR-specific audio device when iRacing is running
    
    The script includes functionality for:
    - Initial configuration and device selection
    - Persistent configuration storage
    - Logging with rotation
    - Automatic audio device switching
    - Error handling and cleanup
    - Graceful shutdown handling

.PARAMETER LogFile
    Path to the log file. Defaults to 'ir-audio-switch.log' in the script directory.

.PARAMETER MaxLogLines
    Maximum number of lines to keep in the log file before rotation. Defaults to 42.

.NOTES
    Version:        1.0
    Author:         Not specified
    Prerequisite:   PowerShell 5.1
    Required Modules: AudioDeviceCmdlets

.EXAMPLE
    .\ir-audio-switch.ps1
    Runs the script with default parameters.

.EXAMPLE
    .\ir-audio-switch.ps1 -LogFile "C:\logs\custom.log" -MaxLogLines 100
    Runs the script with a custom log file location and increased log rotation size.

.INPUTS
    None. Does not accept pipeline input.

.OUTPUTS
    None. Creates and maintains a log file.

.LINK
    https://www.powershellgallery.com/packages/AudioDeviceCmdlets/

.FUNCTIONALITY
    - Audio device management
    - Process monitoring
    - Configuration management
    - Logging
#>
#Requires -Version 5.1

[CmdletBinding()]
param(
    [string]$LogFile = "$(Join-Path $PSScriptRoot 'ir-audio-switch.log')",
    [int]$MaxLogLines = 42
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$configPath = Join-Path $PSScriptRoot "ir-audio-switch.cfg.json"
$script:exitRequested = $false

function Rotate-Log {
    param (
        [string]$logFilePath,
        [int]$maxLines
    )
    if (Test-Path $logFilePath) {
        $logContent = @(Get-Content $logFilePath)  # Force Array mit @()
        if ($logContent.Count -gt $maxLines) {
            $trimmedContent = $logContent[-$maxLines..-1]
            Set-Content -Path $logFilePath -Value $trimmedContent
        }
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error')][string]$Level = 'Info'
    )
    Rotate-Log -logFilePath $LogFile -maxLines $MaxLogLines
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    $consoleMessage = "[$Level] $Message"
    switch ($Level) {
        'Warning' { Write-Host $consoleMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $consoleMessage -ForegroundColor Red }
        default   { Write-Host $consoleMessage -ForegroundColor Green }
    }
    Add-Content -Path $LogFile -Value $logMessage
}

if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
    Write-Log "Installing AudioDeviceCmdlets module..." -Level Warning
    Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
}
Import-Module AudioDeviceCmdlets

function Test-AudioDeviceExists {
    param ([string]$deviceName)
    return [bool](Get-AudioDevice -List | Where-Object { $_.Name -eq $deviceName })
}

function Get-SavedConfiguration {
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            
            # Update global MaxLogLines from config ohne Logging
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

function Select-AudioDevice {
    param ([string]$prompt)
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
    $selectedDevice = $devices | Out-GridView -Title $prompt -OutputMode Single
    return $selectedDevice.Name
}

function Set-DefaultAudioDevice {
    param(
        [string]$deviceName,
        [int]$retryCount = 3,
        [int]$retryDelay = 2000  # Erhöht von 1000 auf 2000 ms
    )
    
    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            $audioDevice = Get-AudioDevice -List | Where-Object { $_.Name -eq $deviceName }
            if ($audioDevice) {
                # Prüfe ob das Gerät bereits aktiv ist
                $currentDefault = Get-AudioDevice -Playback
                if ($currentDefault.Name -eq $deviceName) {
                    Write-Log "Audio device '$deviceName' is already active"
                    return $true
                }
                
                Set-AudioDevice -ID $audioDevice.ID
                Start-Sleep -Milliseconds 500  # Kurze Wartezeit nach dem Umschalten
                
                # Verifiziere die Umschaltung
                $newDefault = Get-AudioDevice -Playback
                if ($newDefault.Name -eq $deviceName) {
                    Write-Log "Switched audio device to: $deviceName (Attempt $i/$retryCount)"
                    return $true
                }
                Write-Log "Switch verification failed! (Attempt $i/$retryCount)" -Level Warning
            } else {
                Write-Log "Audio device '$deviceName' not found! (Attempt $i/$retryCount)" -Level Warning
            }
        }
        catch {
            Write-Log "Error setting audio device: $_ (Attempt $i/$retryCount)" -Level Warning
            Start-Sleep -Milliseconds $retryDelay
        }
    }
    Write-Log "Failed to set audio device after $retryCount attempts" -Level Error
    return $false
}

function Initialize-DeviceConfiguration {
    $devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
    
    Write-Log "Starting initial device configuration..."
    Write-Log "Available playback devices:"
    foreach ($device in $devices) {
        $isDefault = $device.Default ? " (Default)" : ""
        Write-Log "- $($device.Name)$isDefault"
    }

    Clear-Host
    Write-Host "Audio Device Selection" -ForegroundColor Cyan
    Write-Host "Select your default and VR audio devices:" -ForegroundColor Yellow
    Write-Host ""
    
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $prefix = $devices[$i].Default ? "*" : " "
        Write-Host "$prefix$i. $($devices[$i].Name)"
    }
    
    do {
        Write-Host "`nSelect default device number [0-$($devices.Count - 1)]: " -NoNewline
        $defaultSelection = Read-Host
        if ($defaultSelection -match '^\d+$' -and [int]$defaultSelection -ge 0 -and [int]$defaultSelection -lt $devices.Count) {
            $defaultDevice = $devices[[int]$defaultSelection].Name
        } else {
            Write-Host "Invalid selection, try again." -ForegroundColor Red
        }
    } while (-not $defaultDevice)
    Write-Log "Selected default device: $defaultDevice"
    
    do {
        Write-Host "`nSelect VR device number [0-$($devices.Count - 1)]: " -NoNewline
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
    param(
        [string]$DefaultDevice,
        [string]$VRDevice
    )
    try {
        $null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
            $script:exitRequested = $true
            $event.Cancel = $true
        }
        
        $script:exitRequested = $false
        
        while (-not $script:exitRequested) {
            $Host.UI.RawUI.WindowTitle = "IR Audio Switch - Monitoring..."
            $iRacingProcess = Get-Process -Name "iRacingSim64DX11" -ErrorAction SilentlyContinue
            
            if ($iRacingProcess) {
                $Host.UI.RawUI.WindowTitle = "IR Audio Switch - iRacing aktiv (VR Audio)"
                if (-not (Set-DefaultAudioDevice $VRDevice)) {
                    throw "VR Device Fehler"
                }
                
                do {
                    Start-Sleep -Milliseconds 250
                    $iRacingProcess = Get-Process -Name "iRacingSim64DX11" -ErrorAction SilentlyContinue
                } while (-not $script:exitRequested -and $iRacingProcess)
                
                if (-not $script:exitRequested) {
                    $Host.UI.RawUI.WindowTitle = "IR Audio Switch - iRacing beendet"
                    if (-not (Set-DefaultAudioDevice $DefaultDevice)) {
                        throw "Default Device Fehler"
                    }
                }
            }
            
            Start-Sleep -Milliseconds 250
        }
    }
    catch {
        Write-Log "Error in process monitoring: $_" -Level Error
        throw
    }
    finally {
        Get-EventSubscriber | Unregister-Event
        Invoke-Cleanup -DefaultDevice $DefaultDevice
    }
}

try {
    $config = Get-SavedConfiguration
    if ($null -eq $config) {
        $config = Initialize-DeviceConfiguration
    }
    
    Write-Log "Starting with configuration:"
    Write-Log "Default device: $($config.defaultDevice)"
    Write-Log "VR device: $($config.vrDevice)"
    Watch-IRacingProcess -DefaultDevice $config.defaultDevice -VRDevice $config.vrDevice
}
catch {
    Write-Log "Critical error: $_" -Level Error
    if ($null -ne $config -and $null -ne $config.defaultDevice) {
        Invoke-Cleanup -DefaultDevice $config.defaultDevice
    }
    exit 1
}