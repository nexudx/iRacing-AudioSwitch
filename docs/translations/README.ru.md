# Переключатель аудиоустройств для iRacing 🎧

<div align="center">
  <img src="./docs/static/img/audio_switcher_banner.jpg" alt="Баннер переключателя аудиоустройств" width="100%" />
</div>

🌍 Переводы README
[中文说明](./docs/translations/README.cn.md) | [日本語の説明](./docs/translations/README.ja.md) | [한국어 설명](./docs/translations/README.ko.md) | [Français](./docs/translations/README.fr.md) | [Português](./docs/translations/README.ptbr.md) | [Türkçe](./docs/translations/README.tr.md) | [Русский](./docs/translations/README.ru.md) | [Español](./docs/translations/README.es.md) | [Italiano](./docs/translations/README.it.md) | [Deutsch](./docs/translations/README.de.md)

✨ Особенности
- 🛠️ Автоматическое обнаружение iRacing
- 🔄 Автоматическое переключение между аудиоустройством по умолчанию и VR
- 🎤 Автоматическое переключение между микрофоном по умолчанию и VR
- 💾 Постоянная конфигурация
- 📜 Подробное логирование с автоматической ротацией логов
- 🔄 Устойчивое к ошибкам переключение аудиоустройств с механизмом повторов
- 👥 Удобная настройка при первом запуске
- 🛑 Чистое завершение с помощью CTRL+C

🚀 Быстрый старт

### Необходимые условия
- Windows PowerShell 5.1 или выше, рекомендуется PowerShell 7+
- Права администратора для первоначальной установки модуля AudioDeviceCmdlets
- Совместимые с Windows 10/11 аудиоустройства
- Программное обеспечение симулятора iRacing

### Установка
1. Скачайте всю папку проекта.
2. Убедитесь, что выполнение скриптов PowerShell разрешено:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Необходимый модуль AudioDeviceCmdlets будет установлен автоматически при первом запуске.

### Первоначальная настройка
1. Запустите скрипт `ir-audio-switch.ps1`.
2. При первом запуске вам будет предложено:
   - Выбрать аудиоустройство по умолчанию.
   - Выбрать VR аудиоустройство.
   - Выбрать микрофон по умолчанию.
   - Выбрать VR микрофон.
3. Выбор будет автоматически сохранен.

### Использование
1. Запустите скрипт:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Скрипт работает в фоновом режиме и отслеживает iRacing:
   - Когда iRacing запускается, автоматически переключается на VR аудиоустройство и VR микрофон.
   - Когда iRacing закрывается, переключается обратно на аудиоустройство и микрофон по умолчанию.
3. Завершите работу скрипта с помощью CTRL+C.

### Конфигурация
Конфигурация хранится в `ir-audio-switch.cfg.json` и содержит:
- Аудиоустройство по умолчанию (`defaultDevice`)
- VR аудиоустройство (`vrDevice`)
- Микрофон по умолчанию (`defaultMic`)
- VR микрофон (`vrMic`)
- Максимальное количество строк в логе (`maxLogLines`)

### Параметры
Скрипт принимает следующие параметры:
- `-LogFile`: Путь к файлу лога (по умолчанию: ir-audio-switch.log в каталоге скрипта)
- `-MaxLogLines`: Максимальное количество строк для сохранения в файле лога (по умолчанию: 42, диапазон: 10-10000)

Пример:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## Примеры конфигурации

Пример конфигурации в `ir-audio-switch.cfg.json` для типичной VR гоночной установки:

```json
{
  "defaultDevice": "Speakers (Realtek High Definition Audio)",
  "vrDevice": "Headphones (Oculus Virtual Audio Device)",
  "defaultMic": "Microphone (Realtek High Definition Audio)",
  "vrMic": "Microphone (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Устранение неполадок

Если вы столкнулись с проблемами, попробуйте следующие шаги:

1. Убедитесь, что ваши аудиоустройства правильно подключены и распознаны Windows.
2. Проверьте файл лога на наличие сообщений об ошибках.
3. Убедитесь, что у вас есть необходимые права для запуска скрипта и изменения аудиоустройств.
4. Повторно запустите первоначальную настройку, если вы изменили аудиоустройства.

## Лицензия

Этот проект распространяется по лицензии MIT. Для получения более подробной информации см. файл `LICENSE`.