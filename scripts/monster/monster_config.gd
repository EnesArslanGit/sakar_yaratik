class_name MonsterConfig
## Yaratığın TÜM ayarları burada. Kullanıcı "daha hızlı olsun" derse sadece burası değişir.
## (Oyuncu: yürüme 2.6, koşma 4.6 m/s)

# --- Hız (m/s) ---
const PATROL_SPEED := 1.5        # devriye: oyuncunun yürüyüşünden yavaş
const SUSPICIOUS_SPEED := 2.2    # ses duyunca
const CHASE_SPEED := 3.6         # kovalama: yürüyüşten hızlı, koşudan yavaş
const SEARCH_SPEED := 1.8
const TURN_SPEED := 6.0          # dönme hızı (rad/sn)

# --- Görme / duyma ---
const SIGHT_RANGE_DARK := 7.0    # oyuncunun feneri kapalıyken
const SIGHT_RANGE_LIGHT := 13.0  # feneri açıkken
const SIGHT_FOV_DEG := 120.0
const CLOSE_SENSE := 1.8         # bu mesafede arkasındaki oyuncuyu da fark eder
const LOSE_SIGHT_TIME := 3.5     # görüşü bu kadar kaybederse aramaya geçer
const SEARCH_TIME := 7.0         # son görülen yerde arama süresi
const SUSPICIOUS_LOOK_TIME := 3.0

# --- Gürültü yarıçapları (m) ---
const NOISE_RUN := 8.0
const NOISE_WALK := 2.5
const NOISE_DOOR := 6.0

# --- Yakalama ---
const CATCH_DISTANCE := 1.2
const SECOND_CHANCE_PROB := 0.5  # ilk yakalamada son anda düşme ihtimali (oyunda 1 kez)
const SECOND_CHANCE_TIME := 2.0  # "KAÇ!" süresi
const START_GRACE := 3.0         # ortaya çıktıktan sonra bu kadar sn yakalayamaz

# --- Sakarlık (Aşama 3) ---
const CLUMSY_MIN_GAP := 6.0      # iki sakarlık arası en az süre
const CLUMSY_STUN_MIN := 1.5
const CLUMSY_STUN_MAX := 4.0
const TRIP_CHANCE_PATROL := 0.03 # saniyede ayağa takılma ihtimali (devriye)
const TRIP_CHANCE_CHASE := 0.09  # saniyede (kovalarken daha sık)
const DOOR_BONK_CHANCE := 0.4    # kapıdan geçerken kafa çarpma
const DOOR_STUCK_CHANCE := 0.25  # kovalarken kapıda sıkışma
const KNOCK_CHANCE := 0.5        # kırılabilir eşyanın yanından geçerken devirme
const SLIP_CHANCE := 0.35        # halıya basınca kayma
const SNEEZE_CHANCE := 0.012     # saniyede hapşırma (nadir)
const SHADOW_SCARE_TIME := 0.8   # fenerle bu kadar sn yüzüne tutulursa kendi gölgesinden korkar

# --- Görünüm ---
const BODY_SCALE := 1.3          # mankenin 1.83 m boyuna göre
const ARM_STRETCH := 1.4
const LEG_STRETCH := 0.78
const HEAD_SCALE := 0.72
const HUNCH_DEG := 16.0

# --- Devriye noktaları (x, z) ---
const PATROL_POINTS := [
	Vector2(2.0, 3.0), Vector2(4.5, 1.2), Vector2(8.0, 1.6), Vector2(10.5, 3.2),
	Vector2(10.5, 5.0), Vector2(6.0, 5.0), Vector2(1.2, 5.0), Vector2(2.0, 7.0),
	Vector2(5.5, 8.0), Vector2(8.5, 7.5), Vector2(10.0, 8.3), Vector2(3.0, 5.0),
]
const SPAWN := Vector3(10.6, 0.05, 2.0)
