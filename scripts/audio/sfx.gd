class_name Sfx
## Tüm sesler burada, ad ile çalınır. Önce `assets/sounds/` içindeki gerçek kayıt (CREDITS.md) kullanılır;
## dosya yoksa kodla üretilen yedek ses çalar. Yeni/daha iyi ses eklemek için FILES tablosunu değiştir.
## Alan: [dosya(lar), döngü mü, en fazla süre sn (0 = tamamı), başlangıç sn (-1 = rastgele yer)]

const RATE := 22050
const DIR := "res://assets/sounds/"
const FILES := {
	"alarm": [["alarm.mp3"], true, 0.0, 0.0],
	"water": [["water.ogg"], true, 0.0, 0.0],
	"splash": [["splash.ogg"], false, 1.4, 0.0],
	"door_open": [["door_open.ogg"], false, 1.6, 0.0],
	"squeak": [["door_open.ogg"], false, 1.0, 0.0],
	"door_close": [["door_close.wav"], false, 1.2, 0.0],
	"locked": [["locked.wav"], false, 1.0, 0.0],
	"pickup": [["locked.wav"], false, 0.5, 0.0],
	"thud": [["thud.ogg"], false, 0.0, 0.0],
	"step_heavy": [["thud.ogg"], false, 0.0, 0.0],
	"donk": [["hit.mp3"], false, 0.0, 0.0],
	"growl": [["growl1.ogg", "growl2.ogg"], false, 3.0, -1.0],
	"whimper": [["growl2.ogg"], false, 1.2, -1.0],
	"laugh": [["laugh.ogg"], false, 3.0, -1.0],
	"sneeze": [["sneeze.ogg"], false, 2.0, 0.0],
	"glass": [["glass1.wav", "glass2.wav"], false, 2.0, 0.0],
	"pop": [["glass1.wav", "glass2.wav"], false, 1.2, 0.0],
	"heartbeat": [["heartbeat.wav"], true, 0.0, 0.0],
	"breath": [["breath.ogg"], true, 0.0, 0.0],
	"storm": [["storm.ogg"], true, 0.0, -1.0],
}
static var _cache := {}

## pos verilirse 3D konumlu çalar; verilmezse düz (arayüz) sesi. pitch: perde (1 = normal).
static func play(parent: Node, sound: String, pos: Variant = null, volume_db: float = 0.0, pitch: float = 1.0) -> Node:
	var stream := get_stream(sound)
	var info: Array = FILES.get(sound, [[], false, 0.0, 0.0])
	var loop: bool = info[1] or (stream is AudioStreamWAV and (stream as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_DISABLED)
	var pl: Node
	if pos == null:
		var p2 := AudioStreamPlayer.new()
		p2.stream = stream
		p2.volume_db = volume_db
		p2.pitch_scale = pitch
		pl = p2
	else:
		var p3 := AudioStreamPlayer3D.new()
		p3.stream = stream
		p3.volume_db = volume_db
		p3.pitch_scale = pitch
		p3.unit_size = 3.0
		p3.max_distance = 28.0
		pl = p3
	var root := parent.get_tree().current_scene
	root.add_child(pl)
	if pos != null:
		(pl as Node3D).global_position = pos
	var start: float = info[3]
	if start < 0.0:
		start = randf() * maxf(stream.get_length() - maxf(info[2], 1.0), 0.0)
	pl.call("play", start)
	if loop:
		pl.connect("finished", func(): pl.call("play"))
	else:
		pl.connect("finished", pl.queue_free)
		if info[2] > 0.0:
			_stop_later(pl, info[2] / pitch)
	return pl

static func _stop_later(pl: Node, sec: float) -> void:
	await pl.get_tree().create_timer(sec).timeout
	if is_instance_valid(pl):
		var tw := pl.create_tween()
		tw.tween_property(pl, "volume_db", -40.0, 0.25)
		tw.tween_callback(pl.queue_free)

static func get_stream(sound: String) -> AudioStream:
	var info: Array = FILES.get(sound, [[], false, 0.0, 0.0])
	var files: Array = info[0]
	var existing := []
	for f in files:
		if ResourceLoader.exists(DIR + f):
			existing.append(f)
	if not existing.is_empty():
		var pick: String = existing[randi() % existing.size()]
		if not _cache.has(pick):
			_cache[pick] = load(DIR + pick)
		return _cache[pick]
	if not _cache.has(sound):
		_cache[sound] = _make(sound)
	return _cache[sound]

static func _make(sound: String) -> AudioStreamWAV:
	match sound:
		"alarm": return _wav(_alarm(), true)
		"water": return _wav(_water(), true)
		"buzz": return _wav(_buzz(), true)
		"splash": return _wav(_noise_burst(0.7, 0.12, 0.5))
		"sting": return _wav(_sting())
		"pop": return _wav(_pop())
		"door_open": return _wav(_creak(0.9))
		"door_close": return _wav(_thump())
		"locked": return _wav(_rattle())
		"pickup": return _wav(_pickup())
		"door_slam", "thud", "step_heavy", "donk": return _wav(_thump())
		"glass": return _wav(_pop())
		"squeak": return _wav(_creak(0.5))
		"growl", "whimper", "laugh": return _wav(_sting())
		"sneeze": return _wav(_noise_burst(0.6, 0.3, 0.6))
		"heartbeat", "breath", "storm": return _wav(PackedFloat32Array([0.0]))
	push_warning("Bilinmeyen ses: " + sound)
	return _wav(PackedFloat32Array([0.0]))

static func _wav(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_end = samples.size()
	return w

static func _buf(sec: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(sec * RATE))
	return b

## Eski mekanik çalar saat: hızlı bip bip bip, kısa ara.
static func _alarm() -> PackedFloat32Array:
	var b := _buf(1.2)
	for i in b.size():
		var t := float(i) / RATE
		var beep := fmod(t, 0.15) < 0.08 and t < 0.6
		var s := sin(TAU * 2600.0 * t) + 0.5 * sin(TAU * 5200.0 * t)
		b[i] = (0.45 * signf(s) * 0.6 + 0.2 * s) if beep else 0.0
	return b

static func _water() -> PackedFloat32Array:
	var b := _buf(2.0)
	var y := 0.0
	for i in b.size():
		var t := float(i) / RATE
		y += 0.25 * (randf_range(-1, 1) - y)
		b[i] = y * (0.5 + 0.15 * sin(TAU * 7.0 * t) + 0.1 * sin(TAU * 13.0 * t))
	return b

static func _buzz() -> PackedFloat32Array:
	var b := _buf(1.0)
	for i in b.size():
		var t := float(i) / RATE
		var saw := fmod(t * 100.0, 1.0) * 2.0 - 1.0
		b[i] = 0.25 * saw * (1.0 if randf() > 0.02 else 0.0) + 0.05 * randf_range(-1, 1)
	return b

static func _noise_burst(sec: float, smooth: float, vol: float) -> PackedFloat32Array:
	var b := _buf(sec)
	var y := 0.0
	for i in b.size():
		var env := exp(-4.0 * float(i) / b.size())
		y += smooth * (randf_range(-1, 1) - y)
		b[i] = y * env * vol * 3.0
	return b

## Korku vurgusu: uyumsuz akor + ani gürültü.
static func _sting() -> PackedFloat32Array:
	var b := _buf(2.6)
	var freqs := [73.4, 77.8, 155.6, 233.1, 311.1, 466.2, 622.3]
	for i in b.size():
		var t := float(i) / RATE
		var env := minf(t / 0.02, 1.0) * exp(-1.3 * t)
		var s := 0.0
		for f in freqs:
			s += sin(TAU * f * t + 0.3 * sin(TAU * 5.0 * t))
		s /= freqs.size()
		var hit := randf_range(-1, 1) * exp(-12.0 * t)
		b[i] = (s * 0.9 + hit * 0.6) * env
	return b

## Ampul patlaması: kuru pat + cam şıngırtısı.
static func _pop() -> PackedFloat32Array:
	var b := _buf(0.8)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = randf_range(-1, 1) * exp(-60.0 * t) * 0.9
	for k in 8:
		var start := int(randf_range(0.03, 0.45) * RATE)
		var f := randf_range(3000.0, 7000.0)
		for i in range(start, mini(start + int(0.12 * RATE), b.size())):
			var t := float(i - start) / RATE
			b[i] += sin(TAU * f * t) * exp(-35.0 * t) * 0.25
	return b

static func _creak(sec: float) -> PackedFloat32Array:
	var b := _buf(sec)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := 260.0 + 140.0 * sin(TAU * 1.3 * t) + 60.0 * sin(TAU * 7.0 * t)
		phase += TAU * f / RATE
		var env := sin(PI * t / sec)
		var grit := 1.0 if fmod(t * f * 0.25, 1.0) < 0.3 else 0.3
		b[i] = (sin(phase) * 0.5 + signf(sin(phase)) * 0.15) * grit * env * 0.5
	return b

static func _thump() -> PackedFloat32Array:
	var b := _buf(0.35)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = (sin(TAU * 70.0 * t) * 0.9 + randf_range(-1, 1) * 0.3 * exp(-40.0 * t)) * exp(-14.0 * t)
	return b

static func _rattle() -> PackedFloat32Array:
	var b := _buf(0.5)
	for k in 4:
		var start := int((0.03 + k * 0.1) * RATE)
		for i in range(start, mini(start + int(0.05 * RATE), b.size())):
			var t := float(i - start) / RATE
			b[i] += (randf_range(-1, 1) * 0.6 + sin(TAU * 1800.0 * t) * 0.4) * exp(-70.0 * t)
	return b

static func _pickup() -> PackedFloat32Array:
	var b := _buf(0.3)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = sin(TAU * (500.0 + 900.0 * t) * t) * exp(-8.0 * t) * 0.4 + randf_range(-1, 1) * exp(-90.0 * t) * 0.4
	return b
