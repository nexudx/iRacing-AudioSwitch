# IR Audio Switch

This PowerShell script monitors the iRacing process and automatically switches between two configured audio devices:
- A default audio device for normal system use
- A VR-specific audio device when iRacing is running

## Prerequisites
- PowerShell 5.1
- AudioDeviceCmdlets module

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/your-username/ir-audio-switch.git
    cd ir-audio-switch
    ```

2. Install the required modules:
    ```powershell
    Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
    ```

## Usage
Run the script with default parameters:
```powershell
.\ir-audio-switch.ps1
```

## Changelog
All changes to this project are documented in the [CHANGELOG.md](CHANGELOG.md) file.