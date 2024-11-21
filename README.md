# IR Audio Switch

![IR Audio Switch Banner](docs/static/img/audio_switcher_banner.jpg)

A PowerShell module that automatically switches audio devices when launching iRacing. Perfect for VR users who need different audio configurations for VR and desktop use.

## Features

- Automatic audio device switching when iRacing starts/stops
- Supports both playback devices and microphones
- Profile support for different audio configurations
- Robust error handling and automatic recovery
- Detailed logging with configurable levels
- Cross-session configuration persistence

## Requirements

- PowerShell 5.1 or higher
- Windows operating system
- [AudioDeviceCmdlets](https://www.powershellgallery.com/packages/AudioDeviceCmdlets/) module (automatically installed if missing)

## Installation

1. Clone this repository or download the latest release
2. Import the module:
```powershell
Import-Module .\src\IRAudioSwitch.psm1
```

## Usage

### Basic Usage

Start the audio switcher with default settings:

```powershell
Start-AudioSwitcher
```

On first run, you'll be prompted to select your:
- Default audio device (used when iRacing is not running)
- VR audio device (used when iRacing is running)
- Default microphone
- VR microphone

### Advanced Usage

Start with custom logging options:

```powershell
Start-AudioSwitcher -LogFile "C:\logs\ir-audio.log" -MaxLogLines 100 -LogLevel "Debug"
```

### Using Profiles

Save a new audio configuration profile:

```powershell
Save-AudioProfile -ProfileName "my-setup" -Config @{
    defaultDevice = "Speakers"
    vrDevice = "HP Reverb G2"
    defaultMic = "Desktop Mic"
    vrMic = "VR Headset Mic"
}
```

Start the switcher with a saved profile:

```powershell
Start-AudioSwitcher -ProfileName "my-setup"
```

## Parameters

### Start-AudioSwitcher

| Parameter | Description | Default |
|-----------|-------------|---------|
| LogFile | Path to the log file | ir-audio-switch.log |
| MaxLogLines | Maximum number of lines to keep in log file | 42 |
| LogLevel | Logging detail level (Error, Warning, Info, Debug) | Info |
| ProfileName | Name of the audio profile to use | None |

## How It Works

The module:
1. Monitors for the iRacing process (iRacingSim64DX11)
2. When iRacing launches, switches to VR audio devices
3. When iRacing closes, reverts to default audio devices
4. Handles errors and automatically retries failed device switches
5. Maintains a log file for troubleshooting

## Troubleshooting

- Check the log file for detailed error messages
- Ensure all audio devices are properly connected
- Verify device names match exactly in your configuration
- Run PowerShell as administrator if experiencing permission issues

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms of the LICENSE.txt file included in the repository.
