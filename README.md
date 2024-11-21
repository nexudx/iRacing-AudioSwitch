# IR Audio Switch

![IR Audio Switch Banner](docs/static/img/audio_switcher_banner.jpg)

A PowerShell module that automatically switches audio devices when launching iRacing. Perfect for VR users who need different audio configurations for VR and desktop use.

## Features

- Automatic audio device switching when iRacing starts/stops
- Supports both playback devices and microphones
- Robust error handling and automatic recovery
- Detailed logging with configurable levels
- Cross-session configuration persistence

## Requirements

- PowerShell 5.1 or higher
- Windows operating system
- [AudioDeviceCmdlets](https://www.powershellgallery.com/packages/AudioDeviceCmdlets/) module (automatically installed if missing)

## Installation & Usage

You have two ways to use IR Audio Switch:

### 1. Direct Script Execution (Simplest)

Simply run the PowerShell script directly:
```powershell
.\IRAudioSwitch.ps1
```

### 2. Module Import (Recommended for Development)

Import the module using either:
```powershell
# Using the module manifest (recommended)
Import-Module .\src\IRAudioSwitch.psd1

# Or directly import the module file
Import-Module .\src\IRAudioSwitch.psm1

# Then start the audio switcher
Start-AudioSwitcher
```

On first run, you'll be prompted to select your:
- Default audio device (used when iRacing is not running)
- VR audio device (used when iRacing is running)
- Default microphone
- VR microphone

## Advanced Usage

Start with custom logging options:

```powershell
Start-AudioSwitcher -LogFile "C:\logs\ir-audio.log" -MaxLogLines 100 -LogLevel "Debug"
```

## Parameters

### Start-AudioSwitcher

| Parameter | Description | Default |
|-----------|-------------|---------|
| LogFile | Path to the log file | .\src\IRAudioSwitch.log |
| MaxLogLines | Maximum number of lines to keep in log file | 42 |
| LogLevel | Logging detail level (Error=0, Warning=1, Info=2, Debug=3) | Info |

## How It Works

The module:
1. Monitors for the iRacing process (iRacingSim64DX11)
2. When iRacing launches, switches to VR audio devices
3. When iRacing closes, reverts to default audio devices
4. Handles errors and automatically retries failed device switches
5. Maintains a log file for troubleshooting

## Troubleshooting

### Common Issues

1. **Device Not Found Errors**
   - Verify device names exactly match in your configuration
   - Check if devices are properly connected and recognized in Windows
   - Try unplugging and reconnecting problematic devices

2. **Switching Failures**
   - The module will automatically retry failed switches up to 3 times
   - Check the log file for specific error messages
   - Ensure no other applications are blocking audio device changes

3. **Permission Issues**
   - Run PowerShell as administrator
   - Check Windows audio permissions
   - Verify user has write access to the log file location

### Debug Mode

For detailed troubleshooting, run with debug logging:
```powershell
Start-AudioSwitcher -LogLevel Debug
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms of the LICENSE.txt file included in the repository.
