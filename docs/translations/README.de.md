# Audio-Geräte-Umschalter für iRacing 🎧

<div align="center">
  <img src="../static/img/audio_switcher_banner.jpg" alt="Audio-Geräte-Umschalter Banner" width="100%" />
</div>

🌍 README Übersetzungen
[中文说明](README.cn.md) | [日本語の説明](README.ja.md) | [한국어 설명](README.ko.md) | [Français](README.fr.md) | [Português](README.ptbr.md) | [Türkçe](README.tr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Deutsch](README.de.md)

✨ Funktionen
- 🛠️ Automatische Erkennung von iRacing
- 🔄 Automatisches Umschalten zwischen Standard- und VR-Audiogerät
- 🎤 Automatisches Umschalten zwischen Standard- und VR-Mikrofon
- 💾 Persistente Konfiguration
- 📜 Detailliertes Logging mit automatischer Logrotation
- 🔄 Fehlertolerantes Umschalten der Audiogeräte mit Wiederholungsmechanismus
- 👥 Benutzerfreundliche Ersteinrichtung
- 🛑 Sauberer Shutdown mit STRG+C

🚀 Schnellstart

### Voraussetzungen
- Windows PowerShell 5.1 oder höher, PowerShell 7+ empfohlen
- Administratorrechte für die anfängliche Installation des AudioDeviceCmdlets-Moduls
- Windows 10/11 kompatible Audiogeräte
- iRacing-Simulationssoftware

### Installation
1. Laden Sie den gesamten Projektordner herunter.
2. Stellen Sie sicher, dass die Ausführung von PowerShell-Skripten erlaubt ist:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Das benötigte AudioDeviceCmdlets-Modul wird beim ersten Start automatisch installiert.

### Ersteinrichtung
1. Starten Sie das Skript `ir-audio-switch.ps1`.
2. Beim ersten Start werden Sie aufgefordert:
   - Wählen Sie Ihr Standard-Audiogerät.
   - Wählen Sie Ihr VR-Audiogerät.
   - Wählen Sie Ihr Standard-Mikrofon.
   - Wählen Sie Ihr VR-Mikrofon.
3. Die Auswahl wird automatisch gespeichert.

### Nutzung
1. Starten Sie das Skript:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Das Skript läuft im Hintergrund und überwacht iRacing:
   - Wenn iRacing startet, wird automatisch auf das VR-Audiogerät und VR-Mikrofon umgeschaltet.
   - Wenn iRacing geschlossen wird, wird zurück auf das Standard-Audiogerät und Standard-Mikrofon geschaltet.
3. Beenden Sie das Skript mit STRG+C.

### Konfiguration
Die Konfiguration wird in `ir-audio-switch.cfg.json` gespeichert und enthält:
- Standard-Audiogerät (`defaultDevice`)
- VR-Audiogerät (`vrDevice`)
- Standard-Mikrofon (`defaultMic`)
- VR-Mikrofon (`vrMic`)
- Maximale Anzahl von Logzeilen (`maxLogLines`)

### Parameter
Das Skript akzeptiert folgende Parameter:
- `-LogFile`: Pfad zur Logdatei (Standard: ir-audio-switch.log im Skriptverzeichnis)
- `-MaxLogLines`: Maximale Anzahl von Zeilen, die in der Logdatei behalten werden (Standard: 42, Bereich: 10-10000)

Beispiel:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\Pfad\zu\logdatei.log" -MaxLogLines 100
```

## Konfigurationsbeispiele

Beispielkonfiguration in `ir-audio-switch.cfg.json` für ein typisches VR-Rennsetup:

```json
{
  "defaultDevice": "Lautsprecher (Realtek High Definition Audio)",
  "vrDevice": "Kopfhörer (Oculus Virtual Audio Device)",
  "defaultMic": "Mikrofon (Realtek High Definition Audio)",
  "vrMic": "Mikrofon (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Fehlerbehebung

Sollten Sie auf Probleme stoßen, versuchen Sie folgende Schritte:

1. Stellen Sie sicher, dass Ihre Audiogeräte ordnungsgemäß angeschlossen und von Windows erkannt werden.
2. Überprüfen Sie die Logdatei auf Fehlermeldungen.
3. Stellen Sie sicher, dass Sie die notwendigen Berechtigungen haben, um das Skript auszuführen und Audiogeräte zu ändern.
4. Führen Sie die Ersteinrichtung erneut durch, wenn Sie Ihre Audiogeräte geändert haben.

## Lizenzierung

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Details finden Sie in der Datei `LICENSE`.