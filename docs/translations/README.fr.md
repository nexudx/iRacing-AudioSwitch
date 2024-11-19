# Commutateur de périphérique audio pour iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Bannière du commutateur de périphérique audio" width="100%" />
</div>

🌍 Traductions du README
[中文说明](./docs/translations/README.cn.md) | [日本語の説明](./docs/translations/README.ja.md) | [한국어 설명](./docs/translations/README.ko.md) | [Français](./docs/translations/README.fr.md) | [Português](./docs/translations/README.ptbr.md) | [Türkçe](./docs/translations/README.tr.md) | [Русский](./docs/translations/README.ru.md) | [Español](./docs/translations/README.es.md) | [Italiano](./docs/translations/README.it.md) | [Deutsch](./docs/translations/README.de.md)

✨ Fonctionnalités
- 🛠️ Détection automatique d'iRacing
- 🔄 Commutation automatique entre le périphérique audio par défaut et le périphérique VR
- 🎤 Commutation automatique entre le microphone par défaut et le microphone VR
- 💾 Configuration persistante
- 📜 Journalisation détaillée avec rotation automatique des journaux
- 🔄 Commutation tolérante aux pannes des périphériques audio avec mécanisme de réessai
- 👥 Configuration conviviale lors de la première utilisation
- 🛑 Arrêt propre avec CTRL+C

🚀 Démarrage rapide

### Prérequis
- Windows PowerShell 5.1 ou supérieur, PowerShell 7+ recommandé
- Droits administrateur pour l'installation initiale du module AudioDeviceCmdlets
- Périphériques audio compatibles Windows 10/11
- Logiciel de simulation iRacing

### Installation
1. Téléchargez l'ensemble du dossier du projet.
2. Assurez-vous que l'exécution des scripts PowerShell est autorisée :
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Le module AudioDeviceCmdlets requis sera installé automatiquement lors du premier lancement.

### Configuration initiale
1. Démarrez le script `ir-audio-switch.ps1`.
2. Lors du premier lancement, vous serez invité à :
   - Sélectionner votre périphérique audio par défaut.
   - Sélectionner votre périphérique audio VR.
   - Sélectionner votre microphone par défaut.
   - Sélectionner votre microphone VR.
3. La sélection est automatiquement enregistrée.

### Utilisation
1. Démarrez le script :
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Le script s'exécute en arrière-plan et surveille iRacing :
   - Lorsque iRacing démarre, il commute automatiquement vers le périphérique audio VR et le microphone VR.
   - Lorsque iRacing se ferme, il revient au périphérique audio par défaut et au microphone par défaut.
3. Quittez le script avec CTRL+C.

### Configuration
La configuration est stockée dans `ir-audio-switch.cfg.json` et contient :
- Périphérique audio par défaut (`defaultDevice`)
- Périphérique audio VR (`vrDevice`)
- Microphone par défaut (`defaultMic`)
- Microphone VR (`vrMic`)
- Nombre maximum de lignes de journal (`maxLogLines`)

### Paramètres
Le script accepte les paramètres suivants :
- `-LogFile` : Chemin vers le fichier de journalisation (par défaut : ir-audio-switch.log dans le répertoire du script)
- `-MaxLogLines` : Nombre maximum de lignes à conserver dans le fichier de journal (par défaut : 42, plage : 10-10000)

Exemple :

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\chemin\vers\fichier_journal.log" -MaxLogLines 100
```

## Exemples de configuration

Exemple de configuration dans `ir-audio-switch.cfg.json` pour une configuration typique de course VR :

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Dépannage

Si vous rencontrez des problèmes, essayez les étapes suivantes :

1. Assurez-vous que vos périphériques audio sont correctement connectés et reconnus par Windows.
2. Vérifiez le fichier de journal pour tout message d'erreur.
3. Assurez-vous que vous disposez des autorisations nécessaires pour exécuter le script et modifier les périphériques audio.
4. Relancez la configuration initiale si vous avez changé vos périphériques audio.

## Licence

Ce projet est sous licence MIT. Consultez le fichier `LICENSE` pour plus de détails.