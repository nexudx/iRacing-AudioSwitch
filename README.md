# IR Audio Switch

Dieses PowerShell-Skript überwacht den iRacing-Prozess und wechselt automatisch zwischen zwei konfigurierten Audiogeräten:
- Ein Standard-Audiogerät für die normale Systemnutzung
- Ein VR-spezifisches Audiogerät, wenn iRacing läuft

This PowerShell script monitors the iRacing process and automatically switches between two configured audio devices:
- A default audio device for normal system use
- A VR-specific audio device when iRacing is running

## Voraussetzungen / Prerequisites
- PowerShell 5.1
- AudioDeviceCmdlets Modul / Module

## Installation
1. Klone das Repository / Clone the repository:
    ```sh
    git clone https://github.com/dein-benutzername/ir-audio-switch.git
    cd ir-audio-switch
    ```

2. Installiere die erforderlichen Module / Install the required modules:
    ```powershell
    Install-Module -Name AudioDeviceCmdlets -Force -Scope CurrentUser
    ```

## Nutzung / Usage
Führe das Skript mit den Standardparametern aus / Run the script with default parameters:
```powershell
.\ir-audio-switch.ps1
```

## Changelog
Alle Änderungen an diesem Projekt werden in der [CHANGELOG.md](CHANGELOG.md) Datei dokumentiert.