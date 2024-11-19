# Cambia Dispositivo Audio per iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Banner Cambia Dispositivo Audio" width="100%" />
</div>

🌍 Traduzioni README
[中文说明](./docs/translations/README.cn.md) | [日本語の説明](./docs/translations/README.ja.md) | [한국어 설명](./docs/translations/README.ko.md) | [Français](./docs/translations/README.fr.md) | [Português](./docs/translations/README.ptbr.md) | [Türkçe](./docs/translations/README.tr.md) | [Русский](./docs/translations/README.ru.md) | [Español](./docs/translations/README.es.md) | [Italiano](./docs/translations/README.it.md) | [Deutsch](./docs/translations/README.de.md)

✨ Caratteristiche
- 🛠️ Rilevamento automatico di iRacing
- 🔄 Cambio automatico tra dispositivo audio predefinito e VR
- 🎤 Cambio automatico tra microfono predefinito e VR
- 💾 Configurazione persistente
- 📜 Registrazione dettagliata con rotazione automatica dei log
- 🔄 Cambio dispositivo audio tollerante agli errori con meccanismo di ripetizione
- 👥 Configurazione iniziale user-friendly
- 🛑 Spegnimento pulito con CTRL+C

🚀 Avvio Rapido

### Prerequisiti
- Windows PowerShell 5.1 o superiore, PowerShell 7+ raccomandato
- Diritti di amministratore per l'installazione iniziale del modulo AudioDeviceCmdlets
- Dispositivi audio compatibili con Windows 10/11
- Software di simulazione iRacing

### Installazione
1. Scarica l'intera cartella del progetto.
2. Assicurati che l'esecuzione degli script PowerShell sia consentita:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Il modulo richiesto AudioDeviceCmdlets verrà installato automaticamente al primo avvio.

### Configurazione Iniziale
1. Avvia lo script `ir-audio-switch.ps1`.
2. Al primo avvio, ti verrà chiesto di:
   - Selezionare il tuo dispositivo audio predefinito.
   - Selezionare il tuo dispositivo audio VR.
   - Selezionare il tuo microfono predefinito.
   - Selezionare il tuo microfono VR.
3. La selezione viene salvata automaticamente.

### Utilizzo
1. Avvia lo script:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Lo script viene eseguito in background e monitora iRacing:
   - Quando iRacing viene avviato, commuta automaticamente al dispositivo audio VR e al microfono VR.
   - Quando iRacing si chiude, torna al dispositivo audio predefinito e al microfono predefinito.
3. Esci dallo script con CTRL+C.

### Configurazione
La configurazione è memorizzata in `ir-audio-switch.cfg.json` e contiene:
- Dispositivo audio predefinito (`defaultDevice`)
- Dispositivo audio VR (`vrDevice`)
- Microfono predefinito (`defaultMic`)
- Microfono VR (`vrMic`)
- Numero massimo di linee di log (`maxLogLines`)

### Parametri
Lo script accetta i seguenti parametri:
- `-LogFile`: Percorso del file di log (predefinito: ir-audio-switch.log nella directory dello script)
- `-MaxLogLines`: Numero massimo di linee da mantenere nel file di log (predefinito: 42, intervallo: 10-10000)

Esempio:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## Esempi di Configurazione

Esempio di configurazione in `ir-audio-switch.cfg.json` per una tipica configurazione di corsa VR:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Risoluzione dei Problemi

Se riscontri problemi, prova i seguenti passaggi:

1. Assicurati che i tuoi dispositivi audio siano correttamente collegati e riconosciuti da Windows.
2. Controlla il file di log per eventuali messaggi di errore.
3. Assicurati di avere le necessarie autorizzazioni per eseguire lo script e cambiare i dispositivi audio.
4. Esegui nuovamente la configurazione iniziale se hai cambiato i tuoi dispositivi audio.

## Licenza

Questo progetto è concesso in licenza sotto la Licenza MIT. Consulta il file `LICENSE` per maggiori dettagli.