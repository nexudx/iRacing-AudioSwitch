# IR Audio Switch

Dieses PowerShell-Skript überwacht den iRacing-Prozess und wechselt automatisch zwischen zwei konfigurierten Audiogeräten:
- Ein Standard-Audiogerät für die normale Systemnutzung
- Ein VR-spezifisches Audiogerät, wenn iRacing läuft

## Voraussetzungen
- PowerShell 5.1
- AudioDeviceCmdlets Modul

## Installation
1. Klone das Repository:
    ```sh
    git clone https://github.com/dein-benutzername/ir-audio-switch.git
    cd ir-audio-switch
    ```

2. Installiere die erforderlichen Module:
    ```powershell
    Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
    ```

## Nutzung
Führe das Skript mit den Standardparametern aus:
```powershell
.\ir-audio-switch.ps1
```

## Changelog
Alle Änderungen an diesem Projekt werden in der [CHANGELOG.md](CHANGELOG.md) Datei dokumentiert.