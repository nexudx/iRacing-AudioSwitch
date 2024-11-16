# IR Audio Switch

Ein PowerShell-Skript zum automatischen Umschalten der Audioausgabegeräte beim Starten und Stoppen von iRacing.

## Funktionen

- Automatische Erkennung von iRacing
- Automatisches Umschalten zwischen Standard- und VR-Audiogerät
- Persistente Konfiguration
- Detaillierte Protokollierung
- Fehlertolerantes Umschalten der Audiogeräte mit Wiederholungsmechanismus
- Benutzerfreundliche Ersteinrichtung
- Sauberes Herunterfahren mit CTRL+C

## Anforderungen

- Windows PowerShell 5.1 oder höher, PowerShell 7+ wird empfohlen
- Administratorrechte für die anfängliche Installation des AudioDeviceCmdlets-Moduls
- Windows 10/11 kompatible Audiogeräte

## Installation

1. Laden Sie den gesamten Projektordner herunter.
2. Stellen Sie sicher, dass die Ausführung von PowerShell-Skripten erlaubt ist:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Das erforderliche AudioDeviceCmdlets-Modul wird beim ersten Start automatisch installiert.

## Ersteinrichtung

1. Starten Sie das Skript `ir-audio-switch.ps1`.
2. Beim ersten Start werden Sie aufgefordert:
   - Wählen Sie Ihr Standard-Audiogerät
   - Wählen Sie Ihr VR-Audiogerät
3. Die Auswahl wird automatisch gespeichert.

## Verwendung

1. Starten Sie das Skript:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Das Skript läuft im Hintergrund und überwacht iRacing:
   - Wenn iRacing startet, wird automatisch auf das VR-Audiogerät umgeschaltet.
   - Wenn iRacing geschlossen wird, wird wieder auf das Standard-Audiogerät umgeschaltet.
3. Beenden Sie das Skript mit CTRL+C.

## Konfiguration

Die Konfiguration wird in `ir-audio-switch.cfg.json` gespeichert und enthält:
- Standard-Audiogerät (`defaultDevice`)
- VR-Audiogerät (`vrDevice`)
- Maximale Anzahl von Protokollzeilen (`maxLogLines`)

### Parameter

Das Skript akzeptiert die folgenden Parameter:
- `-LogFile`: Pfad zur Protokolldatei (Standard: ir-audio-switch.log im Skriptverzeichnis)
- `-MaxLogLines`: Maximale Anzahl von Protokollzeilen (Standard: 42)

Beispiel:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## Konfigurationsbeispiele

Hier sind einige Beispielkonfigurationen für `ir-audio-switch.cfg.json`:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "maxLogLines": 42
}
```

## Fehlerbehebung

Wenn Sie auf Probleme stoßen, versuchen Sie die folgenden Schritte:

1. Stellen Sie sicher, dass Ihre Audiogeräte ordnungsgemäß angeschlossen und von Windows erkannt werden.
2. Überprüfen Sie die Protokolldatei auf Fehlermeldungen.
3. Stellen Sie sicher, dass Sie die erforderlichen Berechtigungen zum Ausführen des Skripts und zum Ändern der Audiogeräte haben.
4. Führen Sie die Ersteinrichtung erneut durch, wenn Sie Ihre Audiogeräte geändert haben.

## Lizenzierung

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Weitere Details finden Sie in der Datei `LICENSE`.