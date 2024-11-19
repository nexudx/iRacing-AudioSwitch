# Comutador de Dispositivo de Áudio para iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Banner do Comutador de Áudio" width="100%" />
</div>

🌍 Traduções do README
[中文说明](README.cn.md) | [日本語の説明](README.ja.md) | [한국어 설명](README.ko.md) | [Français](README.fr.md) | [Português](README.ptbr.md) | [Türkçe](README.tr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Deutsch](README.de.md)

✨ Recursos
- 🛠️ Detecção automática do iRacing
- 🔄 Troca automática entre dispositivo de áudio padrão e VR
- 🎤 Troca automática entre microfone padrão e VR
- 💾 Configuração persistente
- 📜 Log detalhado com rotação automática
- 🔄 Troca de dispositivo de áudio tolerante a falhas com mecanismo de repetição
- 👥 Configuração inicial amigável
- 🛑 Encerramento limpo com CTRL+C

🚀 Início Rápido

### Pré-requisitos
- Windows PowerShell 5.1 ou superior, PowerShell 7+ recomendado
- Direitos de administrador para instalação inicial do módulo AudioDeviceCmdlets
- Dispositivos de áudio compatíveis com Windows 10/11
- Software de simulação iRacing

### Instalação
1. Baixe toda a pasta do projeto.
2. Certifique-se de que a execução de scripts PowerShell é permitida:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. O módulo necessário AudioDeviceCmdlets será instalado automaticamente na primeira execução.

### Configuração Inicial
1. Inicie o script `ir-audio-switch.ps1`.
2. Na primeira execução, você será solicitado a:
   - Selecionar seu dispositivo de áudio padrão.
   - Selecionar seu dispositivo de áudio VR.
   - Selecionar seu microfone padrão.
   - Selecionar seu microfone VR.
3. A seleção é salva automaticamente.

### Uso
1. Inicie o script:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. O script executa em segundo plano e monitora o iRacing:
   - Quando o iRacing inicia, ele muda automaticamente para o dispositivo de áudio VR e microfone VR.
   - Quando o iRacing fecha, ele retorna ao dispositivo de áudio padrão e microfone padrão.
3. Saia do script com CTRL+C.

### Configuração
A configuração é armazenada em `ir-audio-switch.cfg.json` e contém:
- Dispositivo de áudio padrão (`defaultDevice`)
- Dispositivo de áudio VR (`vrDevice`)
- Microfone padrão (`defaultMic`)
- Microfone VR (`vrMic`)
- Número máximo de linhas de log (`maxLogLines`)

### Parâmetros
O script aceita os seguintes parâmetros:
- `-LogFile`: Caminho para o arquivo de log (padrão: ir-audio-switch.log no diretório do script)
- `-MaxLogLines`: Número máximo de linhas para manter no arquivo de log (padrão: 42, intervalo: 10-10000)

Exemplo:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\caminho\para\arquivo_de_log.log" -MaxLogLines 100
```

## Exemplos de Configuração

Exemplo de configuração em `ir-audio-switch.cfg.json` para uma configuração típica de corrida em VR:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Resolução de Problemas

Se você encontrar algum problema, tente os seguintes passos:

1. Certifique-se de que seus dispositivos de áudio estão corretamente conectados e reconhecidos pelo Windows.
2. Verifique o arquivo de log em busca de mensagens de erro.
3. Assegure-se de que possui as permissões necessárias para executar o script e alterar dispositivos de áudio.
4. Refaça a configuração inicial se você alterou seus dispositivos de áudio.

## Licenciamento

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.