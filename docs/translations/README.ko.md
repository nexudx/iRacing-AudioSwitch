# iRacing용 오디오 디바이스 스위처 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="오디오 디바이스 스위처 배너" width="100%" />
</div>

🌍 README 번역
[中文说明](./docs/translations/README.cn.md) | [日本語の説明](./docs/translations/README.ja.md) | [한국어 설명](./docs/translations/README.ko.md) | [Français](./docs/translations/README.fr.md) | [Português](./docs/translations/README.ptbr.md) | [Türkçe](./docs/translations/README.tr.md) | [Русский](./docs/translations/README.ru.md) | [Español](./docs/translations/README.es.md) | [Italiano](./docs/translations/README.it.md) | [Deutsch](./docs/translations/README.de.md)

✨ 기능
- 🛠️ iRacing 자동 감지
- 🔄 기본 및 VR 오디오 디바이스 간 자동 전환
- 🎤 기본 및 VR 마이크 간 자동 전환
- 💾 지속적인 구성 저장
- 📜 자동 로그 순환을 통한 상세한 로깅
- 🔄 재시도 메커니즘을 통한 내결함성 오디오 디바이스 전환
- 👥 사용자 친화적인 초기 설정
- 🛑 CTRL+C로 깨끗한 종료

🚀 빠른 시작

### 사전 요구사항
- Windows PowerShell 5.1 이상, PowerShell 7+ 권장
- AudioDeviceCmdlets 모듈 초기 설치를 위한 관리자 권한
- Windows 10/11 호환 오디오 디바이스
- iRacing 시뮬레이션 소프트웨어

### 설치
1. 전체 프로젝트 폴더를 다운로드합니다.
2. PowerShell 스크립트 실행이 허용되어 있는지 확인합니다:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. 필요한 AudioDeviceCmdlets 모듈은 첫 실행 시 자동으로 설치됩니다.

### 초기 설정
1. 스크립트 `ir-audio-switch.ps1`를 실행합니다.
2. 첫 실행 시 다음 항목을 선택하라는 메시지가 나타납니다:
   - 기본 오디오 디바이스를 선택합니다.
   - VR 오디오 디바이스를 선택합니다.
   - 기본 마이크를 선택합니다.
   - VR 마이크를 선택합니다.
3. 선택한 내용은 자동으로 저장됩니다.

### 사용법
1. 스크립트를 실행합니다:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. 스크립트는 백그라운드에서 실행되며 iRacing을 모니터링합니다:
   - iRacing이 시작되면 VR 오디오 디바이스와 VR 마이크로 자동 전환됩니다.
   - iRacing이 종료되면 기본 오디오 디바이스와 기본 마이크로 다시 전환됩니다.
3. CTRL+C를 눌러 스크립트를 종료합니다.

### 구성
구성은 `ir-audio-switch.cfg.json`에 저장되며 다음을 포함합니다:
- 기본 오디오 디바이스 (`defaultDevice`)
- VR 오디오 디바이스 (`vrDevice`)
- 기본 마이크 (`defaultMic`)
- VR 마이크 (`vrMic`)
- 최대 로그 라인 수 (`maxLogLines`)

### 매개변수
스크립트는 다음 매개변수를 지원합니다:
- `-LogFile`: 로그 파일의 경로 (기본값: 스크립트 디렉토리의 ir-audio-switch.log)
- `-MaxLogLines`: 로그 파일에 유지할 최대 라인 수 (기본값: 42, 범위: 10-10000)

예시:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## 구성 예시

일반적인 VR 레이싱 설정을 위한 `ir-audio-switch.cfg.json`의 예시 구성:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## 문제 해결

문제가 발생하면 다음 단계를 시도하십시오:

1. 오디오 디바이스가 제대로 연결되고 Windows에서 인식되는지 확인합니다.
2. 로그 파일에서 오류 메시지를 확인합니다.
3. 스크립트를 실행하고 오디오 디바이스를 변경할 수 있는 권한이 있는지 확인합니다.
4. 오디오 디바이스를 변경한 경우 초기 설정을 다시 실행합니다.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하십시오.