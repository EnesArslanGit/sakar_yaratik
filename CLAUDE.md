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
- `project.godot` — ayarlar (Compatibility, MSAA 4x, anizotropik, 1600x900 maksimize)
- `scripts/game/main.gd` — giriş; test arg: `-- pose=x,z,yaw[,pitch] light story=wash wait=sn shot=yol.png`
- `scripts/game/story.gd` — giriş hikâyesi (uyanış→yüz yıkama→ayna korkusu→karartma→fener→kilitli kapı)
- `scripts/game/interactable.gd` — eşyaya KULLAN etkileşimi ekler (`used` sinyali); `input_setup.gd` klavye
- `scripts/world/house_layout.gd` — oda/duvar/kapı/pencere verisi, `openings()`; doğma noktası yatak odası
- `scripts/world/house_builder.gd` — zemin/tavan/duvar, oda kaplaması, süpürgelik, kasalar, lambalar
- `scripts/world/house_furniture.gd` — eşya yerleşimi (M()=model, B()=kırılabilir); hikâye grupları
- `scripts/world/furniture_kit.gd` — tezgâh, buzdolabı, CSG küvet, halı; `bathroom_kit.gd` klozet/lavabo/havlu (Lathe)
- `scripts/world/lathe.gd` — profil döndürerek pürüzsüz mesh; `props.gd` temel şekiller
- `scripts/world/model_lib.gd` — gltf yerleştirme + çarpışma; `materials.gd` dokulu malzemeler
- `scripts/world/interior_door.gd` — menteşeli iç kapı (aç/kapa/kilit); `exit_door.gd` çıkış kapısı
- `scripts/world/window_builder.gd` — pencere, perde, gökyüzü, ay ışığı, `set_all_dark()`
- `scripts/world/mirror.gd` — gerçek ayna (SubViewport); katman 2 = sadece aynada görünen
- `scripts/world/lamp_control.gd` — lamba titreme/patlama; `environment_setup.gd` ortam
- `scripts/monster/scare_face.gd` — aynadaki yaratık yüzü
- `scripts/player/player.gd` — hareket, fener (sonradan), etkileşim hedefi, sinematik kilit, aynadaki beden
- `scripts/ui/touch_controls.gd` — joystick, bakış, KOŞ/KULLAN/(FENER); `hud.gd` görev/altyazı/ipucu/fade
- `scripts/audio/sfx.gd` — kodla üretilen tüm sesler (ad ile)
- `assets/` — Poly Haven CC0 model (1k) / doku (2k)

## Kod kuralları
- Her script tek iş, ≤300 satır. Sahne/eşya/ışık kodla kurulur, .tscn minimum.
- Görsel: kullanıcı gerçekçilik istedi → CC0 gerçek model/doku kullan (plan kural 10 iptal). Sesler hâlâ kodla.
- Yaratık sayıları tek yerde: `scripts/monster/monster_config.gd`.
- Her çalışan adımdan sonra kısa Türkçe commit.

## Şu an neredeyiz
Aşama 1 + görsel + giriş hikâyesi bitti (test bekleniyor). Sıradaki: Aşama 2 yaratık (kapılar AnimatableBody, navigasyon kapıları hesaba katmalı). Sıradaki: Aşama 2 (yaratık, sakarlıksız).

## Bilinen hatalar
- Yok.
