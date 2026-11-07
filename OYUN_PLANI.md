# SAKAR YARATIK — Demo Oyun Planı

> Bu dosya Claude Code için yazılmıştır. Projenin tek kaynak belgesidir.
> Kullanıcı kod bilmiyor ve koda karışmayacak. Kullanıcı sadece oyunu test edip Türkçe geri bildirim verecek.
> Yayınlama, mağaza, reklam, satın alma gibi konular bu aşamada **YOK**. Hedef: oynanabilir bir **demo**.

---

## 0. CLAUDE CODE İÇİN EN ÖNEMLİ KURALLAR (token tasarrufu)

Bu kurallar her şeyden önce gelir. Kullanıcının bütçesi kısıtlı (Pro plan), limit dolmasın.

1. **Hafıza dosyaları:** İlk oturumda proje köküne şu iki dosyayı oluştur ve her oturumda güncel tut:
   - `CLAUDE.md` → En fazla ~60 satır. İçinde: projenin 3 cümlelik özeti, klasör/dosya haritası (her dosya için tek satır: ne işe yarar), kod kuralları, "şu an neredeyiz" bölümü, bilinen hatalar. Claude Code bu dosyayı her oturumda otomatik okur.
   - `docs/ILERLEME.md` → Her oturum sonunda en üste 3-6 satırlık kayıt ekle: tarih, ne yapıldı, hangi dosyalar değişti, sıradaki iş, açık sorunlar. Eski kayıtları silme, ama 30 kaydı geçerse en eskileri tek paragrafta özetle.
2. **Projeyi baştan tarama.** Bir işe başlamadan önce sadece `CLAUDE.md` ve `docs/ILERLEME.md`'nin en üstteki 2-3 kaydını oku. Sonra yalnızca o işle ilgili dosyaları aç. Tüm klasörleri gezme, tüm dosyaları okuma.
3. **Arama yap, okuma değil.** Bir şeyin nerede olduğunu bulmak için önce dosya haritasına bak, sonra gerekiyorsa grep/arama kullan. Büyük dosyayı baştan sona okuma, ilgili kısmı oku.
4. **Küçük dosyalar.** Her script tek bir işe baksın ve 300 satırı geçmesin. Büyürse böl ve haritayı güncelle.
5. **Düzenle, yeniden yazma.** Dosyayı komple yeniden yazmak yerine sadece değişen kısmı düzenle.
6. **Uzun çıktı verme.** Kullanıcıya kod gösterme, dosya içeriğini sohbete dökme. Kullanıcıya her iş sonunda Türkçe, en fazla 5 satırlık özet ver: ne değişti + nasıl test edecek.
7. **Kendin test et.** Kullanıcıya sormadan önce oyunun hatasız açıldığını komut satırından kontrol et (bkz. Bölüm 6). Hata çıktısını kullanıcıya yapıştırtma.
8. **Git ile kayıt al.** Her çalışan adımdan sonra kısa Türkçe mesajla commit at. Bir şey bozulursa geri dönülebilsin; aynı hatayı tekrar tekrar düzeltmekle token harcanmasın.
9. **Sahne dosyalarını (.tscn) minimumda tut.** Mekanı, eşyaları, ışıkları ve karakterleri mümkün olduğunca GDScript ile kodda oluştur. `.tscn` dosyalarını elle büyük büyük yazma; kısa ve basit tut.
10. **Dış dosya indirme yok.** Görseller ve modeller Godot'nun hazır şekillerinden (kutu, kapsül, küre, silindir) kodla üretilecek. Böylece indirme, lisans, import sorunu çıkmaz.
11. **Belirsizlikte en makul olanı seç ve not düş.** Küçük kararlar için kullanıcıya soru sorma; kararı `docs/ILERLEME.md`'ye bir satır olarak yaz. Sadece oyunun hissini ciddi değiştirecek konularda tek bir kısa soru sor.

---

## 1. OYUNUN FİKRİ

**Tür:** Komik korku (korku + komedi), birinci şahıs, 3D, mobil.

**Hikâye (tek cümle):** Oyuncu gece yarısı eski, karanlık bir evde mahsur kalır; evde onu kovalayan dev bir yaratık vardır, ama bu yaratık inanılmaz derecede sakardır.

**Ana fikir:** Yaratığın sakarlığı hem komik hem de oyunun mekaniğidir. Yaratık bir şeylere çarptıkça, düştükçe, bir şeyleri devirdikçe **gürültü** çıkar. Bu gürültü:
- Oyuncuya yaratığın nerede olduğunu söyler (ipucu),
- Ama yaratık çok sakar olsa da **tehlikelidir**; yakalarsa oyun biter.

**Ton:** Karanlık, gergin atmosfer + aniden gelen komik anlar. Korku hissi bozulmasın ama oyuncu gülsün. Kan, vahşet, gore **yok**.

**Demo süresi hedefi:** 5-10 dakikada bitirilebilir.

---

## 2. DEMO KAPSAMI (bundan fazlasını yapma)

### Mekan
Tek katlı küçük bir ev, 4 oda + 1 koridor:
1. **Giriş / Salon** (başlangıç noktası, çıkış kapısı burada, kilitli)
2. **Mutfak**
3. **Yatak odası** (içinde saklanılabilen bir dolap)
4. **Banyo**
5. **Koridor** (odaları birbirine bağlar)

### Hedef
Evin içine dağılmış **3 anahtar parçası** bul → çıkış kapısına götür → kapı açılır → kaçış → "DEMO BİTTİ" ekranı.

### Oyuncu yapabilecekleri
- Yürümek (sol taraftaki sanal joystick)
- Etrafa bakmak (ekranın sağ yarısında parmak kaydırma)
- Fenerini açıp kapamak (buton)
- Etkileşim (buton): anahtar almak, kapı açmak, dolaba saklanmak/çıkmak
- Koşmak (buton, basılı tutunca; dayanıklılık barı var, bitince yavaşlar)

### Yaratık
Bölüm 4'te ayrıntılı. Kısaca: devriye gezer, oyuncuyu görünce/duyunca kovalar, sürekli sakarlık yapar.

### Kapsam DIŞI (demo için yapma)
Kayıt sistemi, birden fazla bölüm, ayarlar menüsünde gelişmiş seçenekler, dil seçimi, reklam, satın alma, mağaza, çevrimiçi özellik, başarımlar.

---

## 3. TEKNİK SEÇİMLER

| Konu | Seçim | Neden |
|---|---|---|
| Oyun motoru | **Godot 4** (en son kararlı sürüm, *Standard* sürüm, .NET değil) | Ücretsiz, dosyaları metin tabanlı, Claude Code için en uygunu |
| Dil | **GDScript** | Godot'nun kendi dili, ek kurulum yok |
| Renderer | **Compatibility** | Eski ve ucuz telefonlarda da çalışır |
| Ekran yönü | **Yatay (landscape)** | Joystick + bakış kontrolü için |
| Görsel tarz | **Low-poly, basit şekiller** | Dış dosya gerekmez, tutarlı ve şık görünür |
| Ses | Kodla üretilen basit sesler (bkz. Bölüm 5) | İndirme yok |
| Test | Önce bilgisayarda, fareyle dokunma taklidi | Telefon kurulumu sonra |

**Proje ayarları (ilk kurulumda yap):**
- Pencere: 1280x720, yatay, `stretch mode = canvas_items`, `aspect = expand`
- `input_devices/pointing/emulate_touch_from_mouse = true` → bilgisayarda fareyle tıklama dokunma gibi çalışsın
- Bilgisayarda test kolaylığı için klavye kısayolları da ekle: WASD yürü, fare bak, F fener, E etkileşim, Shift koş, Esc duraklat. (Mobil kontroller asıl kontrol; klavye sadece test içindir.)

**Önerilen klasör yapısı:**
```
/ (proje kökü)
  CLAUDE.md
  OYUN_PLANI.md          (bu dosya)
  project.godot
  docs/ILERLEME.md
  scenes/main.tscn       (sade; her şeyi scriptler kurar)
  scripts/
    game/      (oyun akışı, anahtar sayacı, kazanma/kaybetme)
    player/    (hareket, kamera, fener, dayanıklılık)
    monster/   (yapay zekâ, sakarlık olayları, görünüm)
    world/     (ev kurulumu, odalar, eşyalar, ışıklar)
    ui/        (joystick, butonlar, HUD, menüler)
    audio/     (ses üretimi ve çalma)
```

---

## 4. YARATIK (oyunun kalbi — en çok özen buraya)

### Görünüm (kodla, basit şekillerden)
- Uzun, hafif kambur bir gövde (kapsül), oyuncudan ~1.5 kat uzun
- Gövdeye göre **küçük ve yuvarlak kafa**, iki büyük parlayan göz (emissive küreler; karanlıkta görünsün, korkutucu ama biraz sevimsiz-sevimli)
- Çok uzun, sallanan kollar (ince silindirler)
- Kısa, tıknaz bacaklar → orantısızlık sakarlığı görsel olarak da anlatır
- Koyu, mat bir renk (koyu mor/gri); gözler sarımsı-yeşil
- Basit "animasyonlar" kodla: yürürken gövdenin hafif sallanması, kolların sarkıp sallanması, düşerken dönme/yere kapaklanma, kalkarken silkinme. İskelet animasyonu kullanma; düğümleri kodla döndür/kaydır (tween).

### Davranış durumları (durum makinesi)
1. **DEVRİYE:** Odalar arasında belirlenen noktalar arasında yavaşça dolaşır.
2. **ŞÜPHE:** Bir ses duyarsa (oyuncu koşarsa, bir şey düşerse) oraya gider, etrafa bakınır.
3. **KOVALAMA:** Oyuncuyu görürse hızlanıp kovalar. Bu sırada sakarlık ihtimali **artar** (aceleden).
4. **ARAMA:** Oyuncuyu kaybederse son gördüğü yerde birkaç saniye dolanır, sonra devriyeye döner.
5. **SAKARLIK ANI:** Aşağıdaki olaylardan biri olur; yaratık 1.5-4 saniye durur. Bitince önceki durumuna döner.

Navigasyon için Godot'nun `NavigationRegion3D` + `NavigationAgent3D` yapısını kullan; navigasyon ağını kod ile ev kurulduktan sonra oluştur (bake).

### Sakarlık olayları (her biri komik, sesli, kısa)
Her olay için: kısa bir hareket + bir ses + ekranın üstünde yaratığın yönünü gösteren küçük bir "gürültü" ikonu (yönlü işaret, 2 saniye).

| # | Olay | Ne olur | Ne zaman |
|---|---|---|---|
| 1 | **Ayağına takılma** | Öne kapaklanır, yere yüz üstü düşer, sonra silkinerek kalkar | Rastgele, kovalarken daha sık |
| 2 | **Kapı çerçevesine kafa çarpma** | Kapıdan geçerken eğilmeyi unutur, "DONK" sesi, kafasını tutar | Kapılardan geçerken %40 ihtimal |
| 3 | **Eşya devirme** | Masadaki vazoyu/tabağı düşürür, kırılma sesi, panikle etrafa bakar | Eşyaların yanından geçerken |
| 4 | **Kapıda sıkışma** | Uzun kolları kapı kasasına takılır, debelenir, sonra "pop" diye kurtulur | Kovalarken kapıdan geçerse %25 |
| 5 | **Halıda kayma** | Halıya basınca kayar, kollarını sallayarak dengesini bulmaya çalışır | Halılı alanlarda |
| 6 | **Hapşırma** | Durur, büyük bir hapşırık sesi, kendi hapşırığından irkilir | Rastgele, nadir |
| 7 | **Kendi gölgesinden korkma** | Fener ışığı onu aydınlatırsa bir an kendi gölgesine bakıp korkar ve geri sıçrar | Oyuncu fenerle ona tutarsa (oyuncuya kaçmak için şans) |

**Denge kuralları:**
- Sakarlık olayları arasında en az 6 saniye olsun (sürekli düşerse korku kalmaz).
- Yaratık normal hızda oyuncudan **biraz yavaş**, kovalarken oyuncunun yürüyüşünden **hızlı**, koşusundan biraz yavaş olsun.
- Tüm bu sayılar tek bir ayar dosyasında (`scripts/monster/monster_config.gd` gibi) sabit olarak dursun, kullanıcı "daha hızlı olsun" dediğinde sadece orası değişsin.

### Yakalama
- Yaratık oyuncuya ~1.2 metre yaklaşırsa yakalar.
- **Komik yakalama sahnesi:** Kamera yaratığa döner, yaratık kollarını açarak üstüne atlar... ve ilk seferde %50 ihtimalle **son anda ayağı takılıp yanına düşer** (oyuncu 2 saniye içinde kaçabilir, ekranda "KAÇ!" yazar). Bu ikinci şans her oyunda **sadece 1 kez** olur.
- Gerçek yakalanmada: kısa ani korkutma (ekran sarsıntısı + ses + yaratığın yüzü yakında), ardından "YAKALANDIN" ekranı ve "Tekrar Dene" butonu. Kan yok.

---

## 5. ATMOSFER, SES, IŞIK

**Işık:**
- Ev çok karanlık; ortam ışığı çok düşük.
- Oyuncunun feneri (SpotLight3D) ana ışık kaynağı. Fenerin pili yok (demo, basit kalsın).
- Birkaç odada titreyen sönük bir ampul (OmniLight3D, rastgele yanıp sönme).
- Hafif sis (WorldEnvironment fog) → derinlik ve gerilim.
- Telefon performansı için gölgeleri sadece fenerde aç, diğer ışıklarda kapalı tut.

**Ses (dosya indirmeden):**
- `AudioStreamGenerator` ile kodda basit sesler üret: gümbürtü (düşme), "donk" (kafa çarpma), kırılma (gürültü patlaması), ayak sesi, kalp atışı (yaratık yaklaştıkça hızlanır), hapşırık (kısa gürültü + perde inişi).
- Sesler 3D konumlu olsun (`AudioStreamPlayer3D`) ki oyuncu yönünü duyabilsin.
- Arka planda düşük, sürekli bir uğultu (ambiyans).
- Ses kodu `scripts/audio/` altında tek bir yerde toplanmalı. İleride kullanıcı gerçek ses dosyası eklemek isterse kolayca değiştirilebilsin (her ses için tek bir fonksiyon/isim).

**Ekran efektleri:** Yaratık yakınken ekran kenarlarında hafif kararma (vignette) ve hafif sarsıntı.

---

## 6. TEST NASIL YAPILACAK

**Claude Code'un kendi kontrolü (her değişiklikten sonra):**
```
godot --headless --path . --quit-after 300
```
Çıktıda `ERROR` veya `SCRIPT ERROR` varsa düzelt, sonra kullanıcıya dön. (`godot` komutu tanınmıyorsa Godot'nun tam yolunu kullan; yolu `CLAUDE.md`'ye bir kez yaz.)

**Kullanıcının testi:** Kullanıcıya her seferinde sadece şunu söyle:
> "Oyunu açmak için: `godot --path .` komutunu çalıştırdım / çalıştırıyorum. Şunu dene: [1-2 cümle]. Nasıl hissettirdi?"

Mümkünse oyunu kullanıcının bilgisayarında sen başlat.

**Hata ayıklama kolaylığı:** Oyunda gizli bir debug modu olsun (klavyede F3): yaratığın durumunu, hızını ve sıradaki sakarlık sayacını ekranda göster. Mobilde görünmesin.

---

## 7. YAPIM SIRASI (aşama aşama, her aşama sonunda dur ve kullanıcıya test ettir)

Her aşama ayrı bir oturum olabilir. Aşama bitince: test et → commit at → `docs/ILERLEME.md` ve `CLAUDE.md`'yi güncelle → kullanıcıya kısa özet + ne test edeceği.

**Aşama 0 — Kurulum kontrolü**
- `godot --version` ve `git --version` çalışıyor mu kontrol et. Çalışmıyorsa kullanıcıya Türkçe, adım adım ne yapacağını söyle.
- Godot projesini oluştur, Bölüm 3'teki ayarları yap, klasörleri kur, `git init`, `CLAUDE.md` ve `docs/ILERLEME.md` oluştur.

**Aşama 1 — Ev ve oyuncu**
- Evi koddan kur: zemin, duvarlar, kapı boşlukları, basit eşyalar (masa, sandalye, yatak, dolap, küvet, vazo, halı) — hepsi basit şekillerden, her odaya farklı renk tonu.
- Oyuncu: birinci şahıs kamera, yürüme, bakma, fener, koşma + dayanıklılık.
- Mobil kontroller: sanal joystick (sol), bakış alanı (sağ), butonlar (Fener, Etkileşim, Koş). Butonlar büyük, yarı saydam, başparmakla kolay basılır.
- ✅ Test: Kullanıcı evde dolaşabiliyor mu, kontroller rahat mı?

**Aşama 2 — Yaratık (sakarlık olmadan)**
- Görünüm, devriye, görme/duyma, kovalama, arama, yakalama + "YAKALANDIN" ekranı.
- ✅ Test: Yaratık korkutucu mu, kaçmak mümkün mü?

**Aşama 3 — Sakarlık**
- Bölüm 4'teki 7 olayın hepsi, sesler, gürültü ikonu, ikinci şans sahnesi.
- ✅ Test: Komik mi? Korku hâlâ var mı? En komik ve en sıkıcı olay hangisi?

**Aşama 4 — Oyun döngüsü**
- 3 anahtar parçası (her oyunda rastgele yerlere), anahtar sayacı (HUD), çıkış kapısı, saklanma dolabı, ana menü (Başla), duraklatma menüsü, "DEMO BİTTİ" ekranı.
- ✅ Test: Baştan sona oynanabiliyor mu? Süre 5-10 dk mı?

**Aşama 5 — Atmosfer ve cila**
- Işık, sis, titreyen ampuller, ambiyans, kalp atışı, vignette, ekran sarsıntısı.
- Performans: telefonda 30+ FPS hedefi (çok obje varsa birleştir, gereksiz ışığı kapat).
- ✅ Test: Atmosfer gergin mi? Takılma var mı?

**Aşama 6 — Telefonda deneme (isteğe bağlı, kullanıcı isterse)**
- Sadece kullanıcının **kendi telefonuna** test için kurulum. Mağaza/yayınlama YOK.
- Android için gerekenleri kullanıcıya adım adım Türkçe anlat (Bölüm 8, Aşama 6 kısmı), Godot'da Android dışa aktarma ayarını yap, APK'yı üret.

---

## 8. KULLANICININ BİLGİSAYARINA KURULACAK PROGRAMLAR

> Bu kısım kullanıcı içindir. Claude Code, Aşama 0'da bunların kurulu olup olmadığını kontrol etmeli; eksik varsa kullanıcıya bu listeye göre tarif etmeli.

### Mutlaka gerekenler
1. **Claude Code**
   - Windows (PowerShell): `irm https://claude.ai/install.ps1 | iex`
   - Mac: `curl -fsSL https://claude.ai/install.sh | bash`
   - Kurulumdan sonra yeni terminal aç, `claude --version` yaz; sürüm numarası çıkmalı.
2. **Git** (Windows için "Git for Windows": git-scm.com) — projenin kayıt noktaları için. Kurulumda varsayılan ayarlarla "Next" demek yeterli.
3. **Godot 4** (godotengine.org → Download → **Standard** sürüm, .NET olmayan)
   - Kurulum yok, zip dosyası. Windows'ta `C:\Godot\` klasörüne çıkar, içindeki uzun isimli `.exe` dosyasının adını `godot.exe` yap.
   - `C:\Godot` klasörünü Windows PATH'ine ekle (Claude Code bunu kullanıcıya adım adım tarif edebilir veya kendisi yapabilir). Böylece `godot` komutu her yerde çalışır.

### Proje klasörü
- Klasörü Türkçe karakter ve boşluk **olmadan** oluştur: örneğin `C:\Oyunlar\SakarYaratik`
  (ğ, ü, ş, ı, ö, ç ve boşluklu yollar bazı araçlarda sorun çıkarıyor.)
- Bu dosyayı (`OYUN_PLANI.md`) o klasörün içine koy.

### Sadece Aşama 6 için (telefonda denemek istenirse, şimdi kurma)
- **OpenJDK 17** (ör. Eclipse Temurin 17)
- **Android Studio** (içindeki Android SDK için) veya Android komut satırı araçları
- Godot içinden **Export Templates** indirme (Editor → Manage Export Templates)
- Telefonda **Geliştirici seçenekleri → USB hata ayıklama** açık, telefon USB ile bilgisayara bağlı
- iPhone için Mac + Xcode + Apple geliştirici hesabı gerekir; demo için Android ile başlamak çok daha kolay.

---

## 9. KULLANICI GERİ BİLDİRİMİNİ NASIL İŞLEYECEKSİN

Kullanıcı teknik terim bilmez. "Yaratık çok hızlı", "burası sıkıcı", "çok karanlık", "kapıda takılıyorum" gibi şeyler diyecek. Bunları:
1. Somut bir değişikliğe çevir (hangi ayar, ne kadar),
2. Sadece ilgili dosyayı düzenle,
3. Kontrol et (Bölüm 6), commit at,
4. Kullanıcıya tek cümleyle ne değiştiğini ve neyi tekrar denemesi gerektiğini söyle,
5. Kararı `docs/ILERLEME.md`'ye bir satır ekle.

Kullanıcı yeni özellik isterse ve bu demo kapsamını (Bölüm 2) büyük ölçüde büyütecekse, önce kısaca "bu demo sonrası için not aldım" de ve `docs/ILERLEME.md` içinde **"Sonraya"** başlığı altına yaz. Küçükse hemen yap.

---

## 10. BAŞARI ÖLÇÜTÜ (demo bitti sayılır, eğer)
- [ ] Oyun açılıyor, ana menüden başlanıyor.
- [ ] Ev dolaşılabiliyor, kontroller (dokunmatik + klavye) rahat.
- [ ] Yaratık devriye geziyor, görünce kovalıyor, yakalayabiliyor.
- [ ] 7 sakarlık olayının hepsi oyunda görülebiliyor ve sesli.
- [ ] 3 anahtar bulunup kapı açılınca "DEMO BİTTİ" ekranı geliyor.
- [ ] Hiç `ERROR` vermiyor, bilgisayarda akıcı çalışıyor.
- [ ] `CLAUDE.md` ve `docs/ILERLEME.md` güncel.
