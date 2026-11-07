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
- `project.godot` — ayarlar (1280x720, canvas_items/expand, Compatibility, fareyle dokunma taklidi)
- `scenes/main.tscn` — sade kök düğüm, `main.gd` bağlı
- `scripts/game/main.gd` — giriş: ortam, ev, oyuncu, UI kurar; test argümanları `-- pose=x,z,yaw[,pitch] shot=yol.png`
- `scripts/game/input_setup.gd` — klavye test kısayolları (WASD, F, E, Shift, Esc, F3)
- `scripts/world/house_layout.gd` — oda/duvar/kapı verileri, doğma noktası (12x10 m ev)
- `scripts/world/house_builder.gd` — zemin, tavan, duvar+kapı boşlukları, tavan lambaları, çıkış kapısı
- `scripts/world/house_furniture.gd` — odalara eşya yerleşimi
- `scripts/world/furniture_kit.gd` — birleşik eşyalar (gruplar: hide_spot, breakable, rug)
- `scripts/world/props.gd` — kutu/silindir/küre + çarpışma, materyal önbelleği
- `scripts/world/environment_setup.gd` — WorldEnvironment (karanlık ortam)
- `scripts/player/player.gd` — hareket, bakış, koşma/dayanıklılık, fener, sağ tık = fare yakalama
- `scripts/ui/touch_controls.gd` — joystick (sol), bakış (sağ), KOŞ/KULLAN/FENER butonları
- `scripts/ui/hud.gd` — nişangâh, dayanıklılık barı, PC ipucu yazısı
- Ekran görüntüsüyle kendin kontrol et: `godot_console.exe --path . -- pose=... shot=<scratchpad>/x.png`

## Kod kuralları
- Her script tek iş, ≤300 satır. Sahne/eşya/ışık kodla kurulur, .tscn minimum.
- Dış dosya yok: şekiller Godot primitive'leri, sesler AudioStreamGenerator.
- Yaratık sayıları tek yerde: `scripts/monster/monster_config.gd`.
- Her çalışan adımdan sonra kısa Türkçe commit.

## Şu an neredeyiz
Aşama 1 bitti (kullanıcı testi bekleniyor). Sıradaki: Aşama 2 (yaratık, sakarlıksız).

## Bilinen hatalar
- Yok.
