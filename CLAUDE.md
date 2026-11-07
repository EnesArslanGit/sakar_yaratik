# Sakar Yaratık — Claude Code hafızası

## Özet
Birinci şahıs, 3D, mobil (yatay) komik-korku DEMO. Oyuncu karanlık evde 3 anahtar parçası bulup kaçar;
onu kovalayan dev yaratık çok sakardır, sakarlıkları gürültü çıkarıp ipucu verir. Tam plan: `OYUN_PLANI.md`.
Kullanıcı kod bilmez; sadece test eder, Türkçe geri bildirim verir. Özetler ≤5 satır, kod gösterme.

## Araçlar
- Godot 4.7.2 Standard: `C:\Godot\godot.exe` (pencereli), `C:\Godot\godot_console.exe` (komut satırı). PATH'te `C:\Godot`.
- Kontrol: `C:\Godot\godot_console.exe --headless --path C:\Oyunlar\SakarYaratik --quit-after 300` → ERROR/SCRIPT ERROR olmamalı.
- Yeni class_name eklendiyse önce `--headless --import` çalıştır (sınıf önbelleği).
- Oyunu kullanıcıya açmak: `C:\Godot\godot.exe --path C:\Oyunlar\SakarYaratik`

## Dosya haritası
- `project.godot` — ayarlar (1280x720, canvas_items/expand, Compatibility, fareyle dokunma taklidi)
- `scenes/main.tscn` — sade kök düğüm, `main.gd` bağlı
- `scripts/game/main.gd` — giriş noktası, her şeyi koddan kurar
- `scripts/game/input_setup.gd` — klavye test kısayolları (WASD, F, E, Shift, Esc, F3)
- `scripts/player|monster|world|ui|audio/` — henüz boş

## Kod kuralları
- Her script tek iş, ≤300 satır. Sahne/eşya/ışık kodla kurulur, .tscn minimum.
- Dış dosya yok: şekiller Godot primitive'leri, sesler AudioStreamGenerator.
- Yaratık sayıları tek yerde: `scripts/monster/monster_config.gd`.
- Her çalışan adımdan sonra kısa Türkçe commit.

## Şu an neredeyiz
Aşama 0 bitti. Sıradaki: Aşama 1 (ev + oyuncu + mobil kontroller).

## Bilinen hatalar
- Yok.
