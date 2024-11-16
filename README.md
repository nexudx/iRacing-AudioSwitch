# IR Audio Switch

Ein PowerShell-Script zur automatischen Umschaltung von Audio-Ausgabegeräten beim Start und Beenden von iRacing.

## Funktionen

- Automatische Erkennung von iRacing
- Automatische Umschaltung zwischen Standard- und VR-Audiogerät
- Persistente Konfiguration
- Ausführliches Logging
- Fehlertolerante Audiogeräte-Umschaltung mit Retry-Mechanismus
- Benutzerfreundliche Ersteinrichtung
- Sauberes Herunterfahren mit CTRL+C

## Voraussetzungen

- Windows PowerShell 5.1 oder höher
- Administratorrechte für die Erstinstallation des AudioDeviceCmdlets-Moduls
- Windows 10/11 kompatible Audiogeräte

## Installation

1. Laden Sie den gesamten Projektordner herunter
2. Stellen Sie sicher, dass die Ausführung von PowerShell-Skripten erlaubt ist:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Beim ersten Start wird das benötigte AudioDeviceCmdlets-Modul automatisch installiert

## Ersteinrichtung

1. Starten Sie das Script `ir-audio-switch.ps1`
2. Bei der ersten Ausführung werden Sie aufgefordert:
   - Ihr Standard-Audiogerät auszuwählen
   - Ihr VR-Audiogerät auszuwählen
3. Die Auswahl wird automatisch gespeichert

## Verwendung

1. Starten Sie das Script:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Das Script läuft im Hintergrund und überwacht iRacing:
   - Beim Start von iRacing wird automatisch zum VR-Audiogerät gewechselt
   - Beim Beenden von iRacing wird zum Standard-Audiogerät zurückgeschaltet
3. Beenden Sie das Script mit CTRL+C

## Konfiguration

Die Konfiguration wird in `ir-audio-switch.cfg.json` gespeichert und enthält:
- Standard-Audiogerät (`defaultDevice`)
- VR-Audiogerät (`vrDevice`)
- Maximale Anzahl der Log-Zeilen (`maxLogLines`)

### Parameter

Das Script akzeptiert folgende Parameter:
- `-LogFile`: Pfad zur Log-Datei (Standard: ir-audio-switch.log im Scriptverzeichnis)
- `-MaxLogLines`: Maximale Anzahl der Log-Zeilen (Standard: 42)

Beispiel: