class_name Sfx
## Tüm sesler burada, kodla üretilir (dosya yok). Her sesin tek bir adı var:
## alarm, water, splash, sting, pop, buzz, door_open, door_close, locked, pickup.
## İleride gerçek ses dosyası eklenirse sadece _make() içinde o ada dosya yüklemek yeter.

const RATE := 22050
static var _cache := {}

## pos verilirse 3D konumlu çalar; verilmezse düz (arayüz) sesi.
static func play(parent: Node, sound: String, pos: Variant = null, volume_db: float = 0.0) -> Node:
	var stream := get_stream(sound)
	var pl: Node
	if pos == null:
		var p2 := AudioStreamPlayer.new()
		p2.stream = stream
		p2.volume_db = volume_db
		pl = p2
	else:
		var p3 := AudioStreamPlayer3D.new()
		p3.stream = stream
		p3.volume_db = volume_db
		p3.unit_size = 3.0
		p3.max_distance = 25.0
		pl = p3
	var root := parent.get_tree().current_scene
	root.add_child(pl)
	if pos != null:
		(pl as Node3D).global_position = pos
	pl.call("play")
	if stream.loop_mode == AudioStreamWAV.LOOP_DISABLED:
		pl.connect("finished", pl.queue_free)
	return pl

static func get_stream(sound: String) -> AudioStreamWAV:
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
