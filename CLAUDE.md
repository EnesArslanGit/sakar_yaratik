# Sakar Yaratık — Claude Code hafızası

## Özet
Birinci şahıs, 3D, mobil (yatay) komik-korku DEMO. Oyuncu karanlık evde 3 anahtar parçası bulup kaçar;
onu kovalayan dev yaratık çok sakardır, sakarlıkları gürültü çıkarıp ipucu verir. Tam plan: `OYUN_PLANI.md`.
Kullanıcı kod bilmez; sadece test eder, Türkçe geri bildirim verir. Özetler ≤5 satır, kod gösterme.

## Araçlar
- Godot 4.7.2 Standard: `C:\Godot\godot.exe` (pencereli), `C:\Godot\godot_console.exe` (komut satırı). PATH'te `C:\Godot`.
- Kontrol: `C:\Godot\godot_console.exe --headless --path E:\oyunlar\SakarYaratik --quit-after 300` → ERROR/SCRIPT ERROR olmamalı.
- Yeni class_name eklendiyse önce `--headless --import` çalıştır (sınıf önbelleği).
- Oyunu kullanıcıya açmak: `C:\Godot\godot.exe --path E:\oyunlar\SakarYaratik`

## Dosya haritası
- `project.godot` — Compatibility, MSAA 4x, anizotropik, 1600x900 maksimize, nav hücre 0.1
- `scripts/game/main.gd` — giriş; test arg: `-- pose=x,z,yaw[,pitch] light story=wash|dark|win menu debug log wait=sn shot=yol.png`
- `scripts/game/story.gd` — menü→uyanış→ayna korkusu→karartma→fener→anahtar→kaçış; checkpoint (Tekrar Dene karanlıktan)
- `scripts/game/catch_sequence.gd` — yakalama (1 kez son anda tökezleme "KAÇ!"), `key_hunt.gd` 3 anahtar parçası
- `scripts/game/hide_spot.gd` — yatak odası dolabına saklanma; `noise_bus.gd` gürültü (NoiseBus); `interactable.gd` KULLAN
- `scripts/monster/monster.gd` — durum makinesi (devriye/şüphe/kovalama/arama/sakar/yakala), NavigationAgent3D
- `scripts/monster/monster_clumsy.gd` — 7 sakarlık olayı; `monster_config.gd` TÜM sayılar
- `scripts/monster/monster_body.gd` — UAL manken + `proportion_mod.gd` (uzun kol, kısa bacak, kambur) + yüz
- `scripts/world/house_*.gd` — ev verisi/kurulum/eşyalar; `nav_builder.gd` navmesh (kapılar katman 2, ağı kesmez)
- `scripts/world/` diğer: interior_door, exit_door, window_builder, mirror, lamp_control, lathe, bathroom_kit, furniture_kit, model_lib, materials, props
- `scripts/player/player.gd` — hareket, fener, etkileşim, gürültü, saklanma, aynadaki manken
- `scripts/ui/` — touch_controls (joystick, KOŞ/KULLAN/FENER/II), hud (görev, ping, vinyet, F3), screens (menü/duraklat/yakalandın/bitti)
- `scripts/audio/sfx.gd` — ad→dosya tablosu (`assets/sounds`, CREDITS.md), yoksa kodla yedek ses
- `assets/` — Poly Haven CC0 model/doku, Quaternius UAL CC0 karakter, Commons sesleri

## Kod kuralları
- Her script tek iş, ≤300 satır. Sahne/eşya/ışık kodla kurulur, .tscn minimum.
- Görsel: kullanıcı gerçekçilik istedi → CC0 gerçek model/doku kullan (plan kural 10 iptal). Sesler hâlâ kodla.
- Yaratık sayıları tek yerde: `scripts/monster/monster_config.gd`.
- Her çalışan adımdan sonra kısa Türkçe commit.

## Şu an neredeyiz
Aşama 0-5 bitti, demo baştan sona oynanabilir. Kullanıcı testi bekleniyor. Fiziksel katmanlar: 1 dünya, 2 iç kapılar, 4 yaratık; görsel katman 2 = sadece ayna. Sıradaki: Aşama 2 (yaratık, sakarlıksız).

## Bilinen hatalar
- Yok.
