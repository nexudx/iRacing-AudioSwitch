<#
.SYNOPSIS
    Starts the iRacing Audio Device Switcher.

.DESCRIPTION
    This script starts the iRacing Audio Device Switcher, which automatically switches between default and VR audio devices 
    when iRacing starts or stops. It provides support for multiple profiles, detailed logging, and robust error handling.

.PARAMETER LogFile
    Path to the log file. Defaults to 'ir-audio-switch.log' in the script directory.

.PARAMETER MaxLogLines
    Maximum number of lines to keep in the log file. Defaults to 42. Valid range is 10-10000.

.PARAMETER LogLevel
    Sets the logging level. Valid values are 'Error', 'Warning', 'Info', 'Debug'. Defaults to 'Info'.

.PARAMETER ProfileName
    Optional name of a saved audio device profile to use.

.EXAMPLE
    .\ir-audio-switch.ps1
    Starts the script with default settings.

.EXAMPLE
    .\ir-audio-switch.ps1 -LogFile "C:\logs\audio-switch.log" -MaxLogLines 100 -LogLevel Debug
    Starts the script with custom logging settings.

.EXAMPLE
    .\ir-audio-switch.ps1 -ProfileName "racing"
    Starts the script using a saved audio device profile.

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
    [int]$MaxLogLines = 42,

    [ValidateSet('Error', 'Warning', 'Info', 'Debug')]
    [string]$LogLevel = 'Info',

    [string]$ProfileName
)

# Import the module
$modulePath = Join-Path $PSScriptRoot "src\IRAudioSwitch.psm1"
if (-not (Test-Path $modulePath)) {
    throw "Module not found at: $modulePath"
}

Import-Module $modulePath -Force

# Start the audio switcher with the provided parameters
$params = @{
    LogFile = $LogFile
    MaxLogLines = $MaxLogLines
    LogLevel = $LogLevel
}

if ($ProfileName) {
    $params['ProfileName'] = $ProfileName
}

Start-AudioSwitcher @params
