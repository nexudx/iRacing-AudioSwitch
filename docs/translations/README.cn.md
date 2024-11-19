# iRacing 音频设备切换器 🎧

<div align="center">
  <img src="../static/img/audio_switcher_banner.jpg" alt="音频设备切换器横幅" width="100%" />
</div>

🌍 README 翻译
[中文说明](README.cn.md) | [日本語の説明](README.ja.md) | [한국어 설명](README.ko.md) | [Français](README.fr.md) | [Português](README.ptbr.md) | [Türkçe](README.tr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Deutsch](README.de.md)

✨ 功能
- 🛠️ 自动检测 iRacing
- 🔄 自动在默认和 VR 音频设备之间切换
- 🎤 自动在默认和 VR 麦克风之间切换
- 💾 持久化配置
- 📜 详细的日志记录，带自动日志轮换
- 🔄 具有重试机制的容错音频设备切换
- 👥 友好的首次设置
- 🛑 使用 CTRL+C 进行干净的关闭

🚀 快速开始

### 先决条件
- Windows PowerShell 5.1 或更高版本，推荐使用 PowerShell 7+
- 初次安装 AudioDeviceCmdlets 模块需要管理员权限
- 兼容 Windows 10/11 的音频设备
- iRacing 模拟软件

### 安装
1. 下载整个项目文件夹。
2. 确保允许执行 PowerShell 脚本：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. 必需的 AudioDeviceCmdlets 模块将在首次启动时自动安装。

### 首次设置
1. 启动脚本 `ir-audio-switch.ps1`。
2. 第一次运行时，您将被提示：
   - 选择您的默认音频设备。
   - 选择您的 VR 音频设备。
   - 选择您的默认麦克风。
   - 选择您的 VR 麦克风。
3. 选择将自动保存。

### 使用方法
1. 启动脚本：
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. 脚本将在后台运行并监控 iRacing：
   - 当 iRacing 启动时，它会自动切换到 VR 音频设备和 VR 麦克风。
   - 当 iRacing 关闭时，它会切换回默认音频设备和默认麦克风。
3. 使用 CTRL+C 退出脚本。

### 配置
配置存储在 `ir-audio-switch.cfg.json` 中，包含：
- 默认音频设备（`defaultDevice`）
- VR 音频设备（`vrDevice`）
- 默认麦克风（`defaultMic`）
- VR 麦克风（`vrMic`）
- 日志行的最大数量（`maxLogLines`）

### 参数
脚本接受以下参数：
- `-LogFile`：日志文件的路径（默认：脚本目录下的 ir-audio-switch.log）
- `-MaxLogLines`：日志文件中保留的最大行数（默认：42，范围：10-10000）

示例：

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## 配置示例

以下是在 `ir-audio-switch.cfg.json` 中的一个典型 VR 赛车设置的配置示例：

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## 疑难解答

如果您遇到任何问题，请尝试以下步骤：

1. 确保您的音频设备已正确连接并被 Windows 识别。
2. 检查日志文件中是否有任何错误信息。
3. 确保您具有运行脚本和更改音频设备的必要权限。
4. 如果您更改了音频设备，请重新运行首次设置。

## 许可证

本项目采用 MIT 许可证。有关详细信息，请参阅 `LICENSE` 文件。