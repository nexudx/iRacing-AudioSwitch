# Audio Device Switcher for iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Audio Device Switcher Banner" width="100%" />
</div>

✨ Features
- 🛠️ Automatic detection of iRacing
- 🔄 Automatic switching between default and VR audio device
- 🎤 Automatic switching between default and VR microphone
- 💾 Persistent configuration with profile support
- 📜 Enhanced logging with configurable levels
- 🔄 Fault-tolerant audio device switching with retry mechanism
- 👥 User-friendly first-time setup with colored indicators
- 🛑 Clean shutdown with CTRL+C
- ✨ Enhanced performance with optimized device monitoring
- 📝 Comprehensive comment-based help
- 🔍 Device health monitoring
- 📊 Multiple profile support

🚀 Quick Start

### Prerequisites
- Windows PowerShell 5.1 or higher
- Administrator rights for initial installation of AudioDeviceCmdlets module (only required once)
- Windows compatible audio devices
- iRacing simulation software

### Installation
1. Download the entire project folder.
2. Ensure PowerShell script execution is allowed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. The required AudioDeviceCmdlets module will be installed automatically on first launch if not present.

### First-Time Setup
1. Start the script `ir-audio-switch.ps1`.
2. On first run, you will be prompted to:
   - Select your default audio device (current default device highlighted in cyan)
   - Select your VR audio device
   - Select your default microphone (current default device highlighted in cyan)
   - Select your VR microphone
3. The selection is automatically saved

### Usage
1. Start the script with default settings:
   ```powershell
   .\ir-audio-switch.ps1
   ```

2. Start with custom logging:
   ```powershell
   .\ir-audio-switch.ps1 -LogFile "C:\logs\audio.log" -MaxLogLines 100 -LogLevel Debug
   ```

3. Use a saved profile:
   ```powershell
   .\ir-audio-switch.ps1 -ProfileName "racing"
   ```

4. The script runs in the background and monitors iRacing:
   - When iRacing starts, it automatically switches to the VR audio device and VR microphone
   - When iRacing closes, it switches back to the default audio device and default microphone
5. Exit the script gracefully with CTRL+C

### Configuration
The configuration is stored in `ir-audio-switch.cfg.json` and contains:
- `defaultDevice`: Your default audio device
- `vrDevice`: Your VR audio device
- `defaultMic`: Your default microphone
- `vrMic`: Your VR microphone
- `maxLogLines`: Maximum number of lines to keep in the log file

### Profiles
You can save multiple device configurations as profiles:

```powershell
# In PowerShell:
Import-Module .\src\IRAudioSwitch.psm1

# Save current configuration as a profile
Save-AudioProfile -ProfileName "racing" -Config @{
    defaultDevice = "Speakers"
    vrDevice = "Valve Index Headset"
    defaultMic = "Desktop Mic"
    vrMic = "Index Mic"
}

# Use a saved profile
.\ir-audio-switch.ps1 -ProfileName "racing"
```

### Parameters
The script accepts the following parameters:
- `-LogFile`: Path to the log file (default: `ir-audio-switch.log` in the script directory)
- `-MaxLogLines`: Maximum number of lines to keep in the log file (default: 42, range: 10-10000)
- `-LogLevel`: Logging detail level (Error, Warning, Info, Debug)
- `-ProfileName`: Name of a saved profile to use

## Configuration Examples

Example configuration in `ir-audio-switch.cfg.json`:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

Example profile in `profiles/racing.json`:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Valve Index Headset",
  "defaultMic": "Blue Yeti",
  "vrMic": "Index Microphone",
  "maxLogLines": 100
}
```

## Advanced Features

### Logging Levels

The script supports four logging levels:
- `Error`: Only critical errors
- `Warning`: Errors and warnings
- `Info`: Normal operation information (default)
- `Debug`: Detailed debugging information

Example:
```powershell
.\ir-audio-switch.ps1 -LogLevel Debug
```

### Device Health Monitoring

The script automatically monitors the health of configured audio devices and will:
- Verify device availability on startup
- Utilize efficient device caching for improved performance
- Retry failed device switches
- Log detailed device state changes
- Monitor iRacing with optimized polling (500ms interval)

### Profile Management

You can manage multiple device configurations:
```powershell
# Save current setup as a profile
Save-AudioProfile -ProfileName "racing" -Config $currentConfig

# Use a saved profile
Get-AudioProfile -ProfileName "racing"
```

## Troubleshooting

If you encounter any issues:

1. Check device availability:
   - Ensure all configured audio devices are properly connected
   - Verify devices are recognized in Windows Sound settings

2. Check logs:
   - Use `-LogLevel Debug` for detailed information
   - Review the log file for error messages

3. Profile issues:
   - Verify profile exists in the profiles directory
   - Check profile JSON format
   - Ensure configured devices are available

4. Performance issues:
   - Check CPU usage (script uses optimized polling to minimize impact)
   - Verify no conflicting audio management software
   - Ensure latest Windows updates are installed

5. Common solutions:
   - Restart the script
   - Reconnect audio devices
   - Re-run first-time setup
   - Clear the log file
   - Create a new profile

## Licensing

This project is licensed under the MIT License. See the `LICENSE` file for more details.
