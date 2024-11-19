# iRacing için Ses Aygıtı Değiştirici 🎧

<div align="center">
  <img src="../static/img/audio_switcher_banner.jpg" alt="Ses Aygıtı Değiştirici Bannerı" width="100%" />
</div>
<div align="center">
  📖 Dokümantasyon | 🎯 Örnekler
</div>

🌍 README Çevirileri
[中文说明](README.cn.md) | [日本語の説明](README.ja.md) | [한국어 설명](README.ko.md) | [Français](README.fr.md) | [Português](README.ptbr.md) | [Türkçe](README.tr.md) | [Русский](README.ru.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Deutsch](README.de.md)

✨ Özellikler
- 🛠️ iRacing'in otomatik algılanması
- 🔄 Varsayılan ve VR ses aygıtı arasında otomatik geçiş
- 🎤 Varsayılan ve VR mikrofonu arasında otomatik geçiş
- 💾 Kalıcı yapılandırma
- 📜 Otomatik log döndürme ile detaylı kayıt
- 🔄 Yeniden deneme mekanizmasıyla hataya dayanıklı ses aygıtı değiştirme
- 👥 Kullanıcı dostu ilk kurulum
- 🛑 CTRL+C ile temiz kapanış

🚀 Hızlı Başlangıç

### Gereksinimler
- Windows PowerShell 5.1 veya üzeri, PowerShell 7+ tavsiye edilir
- AudioDeviceCmdlets modülünün ilk kurulumu için yönetici hakları
- Windows 10/11 uyumlu ses aygıtları
- iRacing simülasyon yazılımı

### Kurulum
1. Tüm proje klasörünü indirin.
2. PowerShell betik yürütmenin izin verildiğinden emin olun:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Gerekli AudioDeviceCmdlets modülü ilk başlatmada otomatik olarak yüklenecektir.

### İlk Kurulum
1. `ir-audio-switch.ps1` betiğini başlatın.
2. İlk çalıştırmada sizden şunları seçmeniz istenecektir:
   - Varsayılan ses aygıtınızı seçin.
   - VR ses aygıtınızı seçin.
   - Varsayılan mikrofonunuzu seçin.
   - VR mikrofonunuzu seçin.
3. Seçimler otomatik olarak kaydedilir.

### Kullanım
1. Betiği başlatın:
   ```powershell
   .\ir-audio-switch.ps1
   ```
2. Betik arka planda çalışır ve iRacing'i izler:
   - iRacing başladığında, otomatik olarak VR ses aygıtına ve VR mikrofonuna geçer.
   - iRacing kapandığında, varsayılan ses aygıtına ve varsayılan mikrofona geri döner.
3. Betiği CTRL+C ile sonlandırabilirsiniz.

### Yapılandırma
Yapılandırma `ir-audio-switch.cfg.json` dosyasında saklanır ve şunları içerir:
- Varsayılan ses aygıtı (`defaultDevice`)
- VR ses aygıtı (`vrDevice`)
- Varsayılan mikrofon (`defaultMic`)
- VR mikrofon (`vrMic`)
- Maksimum log satır sayısı (`maxLogLines`)

### Parametreler
Betik aşağıdaki parametreleri kabul eder:
- `-LogFile`: Log dosyasının yolu (varsayılan: betik dizininde ir-audio-switch.log)
- `-MaxLogLines`: Log dosyasında tutulacak maksimum satır sayısı (varsayılan: 42, aralık: 10-10000)

Örnek:

```powershell
.\ir-audio-switch.ps1 -LogFile "C:\path\to\logfile.log" -MaxLogLines 100
```

## Yapılandırma Örnekleri

Tipik bir VR yarış kurulumu için `ir-audio-switch.cfg.json` dosyasında örnek yapılandırma:

```json
{
  "defaultDevice": "Hoparlörler (Realtek High Definition Audio)",
  "vrDevice": "Kulaklıklar (Oculus Virtual Audio Device)",
  "defaultMic": "Mikrofon (Realtek High Definition Audio)",
  "vrMic": "Mikrofon (Oculus Virtual Audio Device)",
  "maxLogLines": 100
}
```

## Sorun Giderme

Sorun yaşarsanız aşağıdaki adımları deneyin:

1. Ses aygıtlarınızın düzgün bağlandığından ve Windows tarafından tanındığından emin olun.
2. Herhangi bir hata mesajı için log dosyasını kontrol edin.
3. Betiği çalıştırmak ve ses aygıtlarını değiştirmek için gerekli izinlere sahip olduğunuzdan emin olun.
4. Ses aygıtlarınızı değiştirdiyseniz ilk kurulumu yeniden çalıştırın.

## Lisanslama

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.