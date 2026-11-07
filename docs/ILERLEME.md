# İlerleme Kaydı

## 2026-11-08 — Aşama 2-5: Yaratık, sakarlık, oyun döngüsü, atmosfer
- Yaratık: Quaternius UAL manken (CC0, Godot Asset Store'dan) + ProportionMod (kol 1.4, bacak 0.78, kafa 0.72, kambur) + mor-gri deri, parlayan gözler, sırıtış.
- Beyin: navmesh (runtime bake), devriye/şüphe/kovalama/arama, görme (fener açıksa 13 m, kapalı 7 m), duyma (koşu 8 m), kapıları çarparak açar.
- 7 sakarlık (UAL animasyonları: Death01 düşme/geri kalkma, Hit_Head, Interact, Push, Swim_Idle, Hit_Chest, Crouch) + ekranda yön ping'i.
- Döngü: menü, duraklat (Esc/II), 3 anahtar parçası (rastgele odalar), dolaba saklanma, yakalanma (+1 kez KAÇ! şansı), DEMO BİTTİ (süre), Tekrar Dene = karanlıktan devam.
- Atmosfer: karartma sonrası sis, kalp atışı (yaratık yakınlığı), kenar kararması, lambalar ara sıra titrer, fırtına ambiyansı.
- Sesler: Wikimedia Commons (CC0/PD/CC BY), `assets/sounds/CREDITS.md`. İndirme hız sınırı (429) nedeniyle bazıları gecikti; eksik olan kodla yedek çalar.
- Aynadaki oyuncu: aynı manken normal oranda. Korku sahnesinde aynada gerçek yaratık modeli.
- Engellenen: ffmpeg/OpenGameArt indirme izni verilmedi → kırpma oyun içinde (Sfx FILES tablosu, en fazla süre).
- Sonraya: tablolar siyah; Shelf_01 boş; yaratık seslerine özel kayıt (Freesound üyeliği gerekir).

## 2026-11-08 — Kullanıcı kararları (otomatik mod)
- Kullanıcı: "Oyunu bitirene kadar izin istemeden devam et; test edebilirsin ama oyunu bana açma."
- Kaynaklar: sadece üyeliksiz ücretsiz (CC0 vb.) kaynaklar. Yaratık: plandaki görünüm. APK: şimdilik yok.
- Kullanıcı karakteri/yaratığı ve kodla üretilen sesleri beğenmedi → gerçek ses kayıtları ve daha iyi modeller.

## 2026-11-08 — Giriş hikâyesi, kapılar, pencereler, ayna (kullanıcı isteği)
- Hikâye: 03:07 alarm, yatakta uyanış → banyoda yüz yıkama → aynada yaratık → pencereler kararır, lambalar patlar → komodindeki fener → çıkış kilitli.
- Yeni: menteşeli iç kapılar (KULLAN), 5 pencere (perde, ay ışığı), gerçek ayna, lathe porselen klozet/lavabo, banyo/yatak odası eşyaları, kodla sesler.
- Kararlar: fener başta yok (bulununca FENER butonu çıkar); karartma sonrası ortam ışığı 0.1 mavi; aynadaki oyuncu sade siluet.
- Kullanıcının "kapıları açmak için odada kilit" isteği: şimdilik kapılar kapalı/açılabilir, çıkış kilitli; anahtar parçaları Aşama 4.
- Sonraya: tablo resimleri siyah; Shelf_01 boş (kitap yok).

## 2026-11-08 — Görsel yenileme (kullanıcı: "Minecraft gibi küp küp, çözünürlük kötü")
- Kullanıcı kararı: gerçek CC0 doku + model (Poly Haven). 33 model (1k), 11 doku (2k) `assets/` altında.
- Ev: dokulu zemin/duvar/tavan, oda başı farklı kaplama, süpürgelik, kapı kasaları, panelli çıkış kapısı, duy+ampul lamba.
- Kodla detaylı: tezgâh, retro buzdolabı, CSG oyuk ayaklı küvet (+ lastik ördek), klozet, lavabo.
- Kalite: MSAA 4x, anizotropik 8x, pencere büyük açılıyor, glow, gölge atlası 4096.
- Sonraya: resim çerçeveleri ve aynalar siyah görünüyor (yansıma/resim yok), ileride iyileştir.

## 2026-11-08 — Aşama 1: Ev ve oyuncu
- Proje kullanıcı isteğiyle `E:\oyunlar\SakarYaratik`'e taşındı (eski kopya C:\Oyunlar'da kaldı, silinmesi kullanıcıya bırakıldı).
- Ev koddan kuruluyor (5 alan, eşyalar, tavan lambaları, yeşil ÇIKIŞ tabelası). Oyuncu: yürü/koş/dayanıklılık/fener/head-bob.
- Mobil: kayan joystick, sağ yarı bakış, KOŞ/KULLAN/FENER. PC: WASD, sağ tık fare bakışı.
- Kararlar: yürüme 2.6, koşu 4.6 m/s; fener gölge bias 0.08 (çizgilenme giderildi). UI için set_anchors_and_offsets_preset şart.
- Sıradaki: kullanıcı testi → Aşama 2 (yaratık).

## 2026-11-08 — Aşama 0: Kurulum
- Godot 4.7.2 Standard indirildi → `C:\Godot`, kullanıcı PATH'ine eklendi. Git 2.53 zaten vardı.
- Proje `E:\oyunlar\SakarYaratik` içinde kuruldu: project.godot, main.tscn, main.gd, input_setup.gd, klasörler.
- Karar: klavye kısayolları project.godot yerine koddan (InputMap) tanımlandı, dosya sade kalsın.
- Headless test hatasız. Sıradaki: Aşama 1 (ev, oyuncu, joystick/butonlar).
- Açık sorun: yok.

## Sonraya
- (boş)
