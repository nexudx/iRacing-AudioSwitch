# Audio Device Switcher for iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Audio Device Switcher Banner" width="100%" />
</div>

🌍 README Translations
[中文说明](./docs/translations/README.cn.md) | [日本語の説明](./docs/translations/README.ja.md) | [한국어 설명](./docs/translations/README.ko.md) | [Français](./docs/translations/README.fr.md) | [Português](./docs/translations/README.ptbr.md) | [Türkçe](./docs/translations/README.tr.md) | [Русский](./docs/translations/README.ru.md) | [Español](./docs/translations/README.es.md) | [Italiano](./docs/translations/README.it.md) | [Deutsch](./docs/translations/README.de.md)

✨ Features
- 🛠️ Automatic detection of iRacing
- 🔄 Automatic switching between default and VR audio device
- 🎤 Automatic switching between default and VR microphone
- 💾 Persistent configuration
- 📜 Detailed logging
- 🔄 Fault-tolerant audio device switching with retry mechanism
- 👥 User-friendly first-time setup
- 🛑 Clean shutdown with CTRL+C
- ✨ Enhanced performance with audio device caching
- 📝 Comprehensive comment-based help for better understanding and usage

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
3. The required AudioDeviceCmdlets module will be installed automatically on first launch if not already present.

### First-Time Setup
1. Start the script `ir-audio-switch.ps1`.
2. On first run, you will be prompted to:
   - Select your default audio device.
   - Select your VR audio device.
   - Select your default microphone.
   - Select your VR microphone.
3. The selection is automatically saved.

### Usage
1. Start the script:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. The script runs in the background and monitors iRacing:
   - When iRacing starts, it automatically switches to the VR audio device and VR microphone.
   - When iRacing closes, it switches back to the default audio device and default microphone.
3. Exit the script gracefully with CTRL+C.

### Configuration
The configuration is stored in `ir-audio-switch.cfg.json` and contains:
- `defaultDevice`: Your default audio device.
- `vrDevice`: Your VR audio device.
- `defaultMic`: Your default microphone.
- `vrMic`: Your VR microphone.
- `maxLogLines`: Maximum number of lines to keep in the log file.

### Parameters
The script accepts the following parameters:
- `-LogFile`: Path to the log file (default: `ir-audio-switch.log` in the script directory).
- `-MaxLogLines`: Maximum number of lines to keep in the log file (default: 42, range: 10-10000).

Example:
```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## Configuration Examples

Example configuration in `ir-audio-switch.cfg.json` for a typical VR racing setup:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Troubleshooting

If you encounter any issues, try the following steps:

1. Ensure that your audio devices are properly connected and recognized by Windows.
2. Check the log file (`ir-audio-switch.log` by default) for any error messages.
3. Make sure you have the necessary permissions to run the script and change audio devices.
4. Re-run the first-time setup if you have changed your audio devices.

## Licensing

This project is licensed under the MIT License. See the `LICENSE` file for more details.
