# iRacing用オーディオデバイススイッチャー 🎧

<div align="center">
  <img src="../static/img/audio_switcher_banner.jpg" alt="Audio Device Switcher Banner" width="100%" />
</div>

🌍 READMEの翻訳
[中文说明](README.cn.md) | [日本語の説明](README.ja.md) | [한국어 설명](README.ko.md) | [Français](README.fr.md) | [Português](README.ptbr.md) | [Türkçe](README.tr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Deutsch](README.de.md)

✨ 機能
- 🛠️ iRacingの自動検出
- 🔄 デフォルトとVRオーディオデバイス間の自動切り替え
- 🎤 デフォルトとVRマイクロフォン間の自動切り替え
- 💾 永続的な設定保存
- 📜 自動ログローテーションによる詳細なログ
- 🔄 リトライ機構によるフォールトトレラントなオーディオデバイス切り替え
- 👥 初心者に優しい初期設定
- 🛑 CTRL+Cによるクリーンなシャットダウン

🚀 クイックスタート

### 必要条件
- Windows PowerShell 5.1以上（PowerShell 7+を推奨）
- 初回インストール時にAudioDeviceCmdletsモジュールのための管理者権限
- Windows 10/11互換のオーディオデバイス
- iRacingシミュレーションソフトウェア

### インストール
1. プロジェクトフォルダ全体をダウンロードします。
2. PowerShellスクリプトの実行が許可されていることを確認します：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. 必要なAudioDeviceCmdletsモジュールは初回起動時に自動的にインストールされます。

### 初期設定
1. スクリプト `ir-audio-switch.ps1` を開始します。
2. 初回実行時に以下のプロンプトが表示されます：
   - デフォルトのオーディオデバイスを選択します。
   - VRオーディオデバイスを選択します。
   - デフォルトのマイクロフォンを選択します。
   - VRマイクロフォンを選択します。
3. 選択内容は自動的に保存されます。

### 使用方法
1. スクリプトを開始します：
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. スクリプトはバックグラウンドで実行され、iRacingを監視します：
   - iRacingが起動すると、自動的にVRオーディオデバイスとVRマイクロフォンに切り替えます。
   - iRacingが終了すると、デフォルトのオーディオデバイスとデフォルトのマイクロフォンに戻します。
3. CTRL+Cでスクリプトを終了します。

### 設定
設定は `ir-audio-switch.cfg.json` に保存され、以下を含みます：
- デフォルトのオーディオデバイス (`defaultDevice`)
- VRオーディオデバイス (`vrDevice`)
- デフォルトのマイクロフォン (`defaultMic`)
- VRマイクロフォン (`vrMic`)
- 最大ログ行数 (`maxLogLines`)

### パラメータ
スクリプトは以下のパラメータを受け付けます：
- `-LogFile`: ログファイルのパス（デフォルト：スクリプトディレクトリの ir-audio-switch.log）
- `-MaxLogLines`: ログファイルに保持する最大行数（デフォルト：42、範囲：10-10000）

例：

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## 設定例

典型的なVRレーシングセットアップ用の `ir-audio-switch.cfg.json` の設定例：

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## トラブルシューティング

問題が発生した場合、以下の手順を試してください：

1. オーディオデバイスが正しく接続され、Windowsによって認識されていることを確認します。
2. ログファイルでエラーメッセージを確認します。
3. スクリプトの実行とオーディオデバイスの変更に必要な権限があることを確認します。
4. オーディオデバイスを変更した場合は、初期設定を再実行してください。

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細は `LICENSE` ファイルを参照してください。