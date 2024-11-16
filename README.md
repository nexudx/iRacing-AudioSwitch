# IR Audio Switch

A PowerShell script for automatically switching audio output devices when starting and stopping iRacing.

## Features

- Automatic detection of iRacing
- Automatic switching between default and VR audio device
- Persistent configuration
- Detailed logging
- Fault-tolerant audio device switching with retry mechanism
- User-friendly first-time setup
- Clean shutdown with CTRL+C

## Requirements

- Windows PowerShell 5.1 or higher
- Administrator rights for initial installation of AudioDeviceCmdlets module
- Windows 10/11 compatible audio devices

## Installation

1. Download the entire project folder
2. Ensure PowerShell script execution is allowed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. The required AudioDeviceCmdlets module will be installed automatically on first launch

## First-Time Setup

1. Start the script `ir-audio-switch.ps1`
2. On first run, you will be prompted to:
   - Select your default audio device
   - Select your VR audio device
3. The selection is automatically saved

## Usage

1. Start the script:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. The script runs in the background and monitors iRacing:
   - When iRacing starts, it automatically switches to the VR audio device
   - When iRacing closes, it switches back to the default audio device
3. Exit the script with CTRL+C

## Configuration

The configuration is stored in `ir-audio-switch.cfg.json` and contains:
- Default audio device (`defaultDevice`)
- VR audio device (`vrDevice`)
- Maximum number of log lines (`maxLogLines`)

### Parameters

The script accepts the following parameters:
- `-LogFile`: Path to the log file (default: ir-audio-switch.log in script directory)
- `-MaxLogLines`: Maximum number of log lines (default: 42)

Example: