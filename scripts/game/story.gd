class_name Story
extends Node
## Hikâye ve oyun döngüsü:
## 1) Menü → 03:07 alarm, yatakta uyanış → KULLAN ile alarmı kapat.
## 2) Banyoda yüz yıka → aynada yaratık → pencereler kararır, lambalar patlar → yaratık evde dolaşmaya başlar.
## 3) Komodindeki feneri bul.  4) Çıkış kilitli → anahtarın 3 parçasını bul (rastgele yerler).
## 5) Kapıyı aç → DEMO BİTTİ.  Yakalanınca "Tekrar Dene" karanlık bölümden devam eder (checkpoint).

enum Step { WAKE, GO_WASH, WASHING, FIND_LIGHT, ESCAPE, DONE }

static var checkpoint := false      # true: yakalandıktan sonra karanlıktan başla
static var _run_start := 0

var step := Step.WAKE
var player: Player
var hud: Hud
var env: Environment
var monster: Monster
var keys: KeyHunt
var screens: Screens
var _alarm: Node
var _wake_ready := false
var _sink: Node3D
var _sink_it: Interactable
var _mirror: Mirror
var _flashlight: Node3D
var _door_known := false
var _heart: AudioStreamPlayer
var _flicker_t := 8.0

func setup(p: Player, h: Hud, e: Environment, m: Monster, k: KeyHunt, s: Screens) -> void:
	player = p
	hud = h
	env = e
	monster = m
	keys = k
	screens = s
	var tree := get_tree()
	_sink = tree.get_first_node_in_group("sink")
	_mirror = tree.get_first_node_in_group("mirror")
	_flashlight = tree.get_first_node_in_group("flashlight_pickup")
	_sink_it = Interactable.attach(_sink, "Yüzünü yıka", Vector3(0, 0.9, 0), false)
	_sink_it.used.connect(_on_wash)
	Interactable.attach(_flashlight, "Feneri al", Vector3(0, 0.06, 0)).used.connect(_on_flashlight)
	var exit: Node3D = tree.get_first_node_in_group("exit_door")
	Interactable.attach(exit, "Kapıyı aç", Vector3(0, 1.1, 0.15)).used.connect(_on_exit)
	player.interact_requested.connect(_on_any_interact)
	keys.part_found.connect(_on_key)
	keys.all_found.connect(_on_all_keys)
	monster.caught.connect(func(mm): CatchSequence.run(mm, player, hud, screens))
	screens.start_pressed.connect(start)
	screens.retry_pressed.connect(func(): _reload(true))
	screens.restart_pressed.connect(func(): _reload(false))

## Oyun açılınca: checkpoint varsa karanlıktan devam, yoksa ana menü.
func begin() -> void:
	_heart = Sfx.play(self, "heartbeat", null, -60.0) as AudioStreamPlayer
	Sfx.play(self, "storm", null, -18.0)
	if checkpoint:
		_start_dark()
	else:
		hud.fade = 1.0
		screens.show_mode("menu")

func _reload(from_checkpoint: bool) -> void:
	checkpoint = from_checkpoint
	get_tree().paused = false
	get_tree().reload_current_scene()

func _process(d: float) -> void:
	# Karartmadan önce ara sıra bir lamba titrer (gerilim).
	if step in [Step.WAKE, Step.GO_WASH]:
		_flicker_t -= d
		if _flicker_t <= 0.0:
			_flicker_t = randf_range(7.0, 14.0)
			_flicker_one()
	if _heart:
		_heart.volume_db = lerpf(-60.0, -2.0, hud.danger)
		_heart.pitch_scale = 0.9 + hud.danger * 0.35

func _flicker_one() -> void:
	var lamps := get_tree().get_nodes_in_group("lamp")
	var l: Node3D = lamps[randi() % lamps.size()]
	for i in randi_range(2, 4):
		LampControl.set_on(l, false)
		await _wait(randf_range(0.05, 0.15))
		if step not in [Step.WAKE, Step.GO_WASH]:
			return
		LampControl.set_on(l, true)
		await _wait(randf_range(0.05, 0.2))

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func _tween() -> Tween:
	return create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ---------- 1) Uyanış ----------
func start() -> void:
	CatchSequence.second_chance_used = false
	_run_start = Time.get_ticks_msec()
	var clock: Node3D = get_tree().get_first_node_in_group("alarm_clock")
	player.set_cinematic(true)
	player.global_position = Vector3(4.3, -0.72, 9.3)
	player.rotation.y = 0.0
	player.camera.rotation.x = deg_to_rad(72)
	hud.fade = 1.0
	_alarm = Sfx.play(self, "alarm", clock.global_position + Vector3(0, 0.1, 0), 0.0)
	await _wait(1.2)
	hud.caption("03:07", 3.0)
	await hud.fade_to(0.0, 3.0).finished
	hud.caption("Alarmı kapat  (KULLAN)", 60.0)
	_wake_ready = true

func _on_any_interact() -> void:
	if step == Step.WAKE and _wake_ready:
		_wake_ready = false
		_get_up()

func _get_up() -> void:
	_alarm.queue_free()
	Sfx.play(self, "pickup", null, -6.0)
	hud.caption("Of... yine o kâbus. Yüzümü yıkasam iyi olacak.", 4.0)
	var tw := _tween()
	tw.tween_property(player.camera, "rotation:x", deg_to_rad(-8), 1.8)
	tw.tween_property(player, "global_position", Vector3(4.0, -0.6, 8.9), 1.8)
	tw.tween_property(player, "rotation:y", deg_to_rad(40), 1.8)
	await tw.finished
	var tw2 := _tween()
	tw2.tween_property(player, "global_position", HouseLayout.PLAYER_SPAWN, 1.5)
	tw2.tween_property(player, "rotation:y", 0.0, 1.5)
	await tw2.finished
	player.set_cinematic(false)
	step = Step.GO_WASH
	_sink_it.enabled = true
	hud.set_objective("Banyoya git ve yüzünü yıka.")

# ---------- 2) Banyo, ayna, karartma ----------
func _on_wash(_p: Node) -> void:
	if step != Step.GO_WASH:
		return
	step = Step.WASHING
	_sink_it.enabled = false
	player.set_cinematic(true)
	var tw := _tween()
	tw.tween_property(player, "global_position", Vector3(11.05, 0.05, 7.4), 1.0)
	tw.tween_property(player, "rotation:y", deg_to_rad(-90), 1.0)
	tw.tween_property(player.camera, "rotation:x", deg_to_rad(-50), 1.0)
	await tw.finished
	var stream: Node3D = _sink.find_child("WaterStream", true, false)
	stream.visible = true
	var water := Sfx.play(self, "water", _sink.global_position + Vector3(0, 0.9, 0), -4.0)
	hud.caption("Soğuk su iyi gelir...", 2.0)
	await _wait(1.6)
	Sfx.play(self, "splash", null, -2.0)
	await hud.fade_to(1.0, 0.25).finished
	await _wait(0.9)
	water.queue_free()
	stream.visible = false
	player.camera.rotation.x = deg_to_rad(-2)
	await hud.fade_to(0.0, 0.7).finished
	await _wait(1.3)
	await _scare()
	await _blackout()
	player.set_cinematic(false)
	_after_blackout()

## Aynada, omzunun üstünden yaratık bakar (sadece aynada görünür).
func _scare() -> void:
	var ghost := MonsterBody.new()
	ghost.layer_mask = 1 << (Mirror.MIRROR_ONLY_LAYER - 1)
	get_tree().current_scene.add_child(ghost)
	ghost.global_position = Vector3(10.3, 0.0, 7.75)
	ghost.rotation_degrees.y = -100.0
	ghost.play("Crouch_Idle", 1.0, 0.0)
	Sfx.play(self, "growl", null, 6.0, 0.75)
	Sfx.play(self, "donk", null, 2.0, 0.45)
	player.shake = 1.2
	var lunge := create_tween()
	lunge.tween_property(ghost, "global_position", ghost.global_position + Vector3(0.35, 0, -0.1), 1.0).set_ease(Tween.EASE_IN)
	await _wait(1.1)
	var tw := _tween()
	tw.tween_property(player, "rotation:y", deg_to_rad(90), 0.35)
	await tw.finished
	ghost.queue_free()
	await _wait(0.8)
	hud.caption("Ne... neydi o?!", 2.5)

func _blackout() -> void:
	await LampControl.flicker_all(self, 1.8)
	_go_dark()
	player.shake = 0.5
	await LampControl.burst_all(self)
	await _wait(0.8)
	Sfx.play(self, "growl", MonsterConfig.SPAWN + Vector3(0, 2, 0), 4.0, 0.8)
	await _wait(1.0)

func _go_dark() -> void:
	WindowBuilder.set_all_dark(get_tree())
	_mirror.set_dark(true)
	env.ambient_light_energy = 0.1
	env.ambient_light_color = Color(0.35, 0.4, 0.6)
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.06, 0.09)
	env.fog_density = 0.04

func _after_blackout() -> void:
	monster.activate(MonsterConfig.SPAWN)
	keys.spawn()
	if player.has_flashlight:
		_to_escape()
	else:
		step = Step.FIND_LIGHT
		hud.caption("Hiçbir şey göremiyorum! ...Ve o ses de neydi?", 3.5)
		hud.set_objective("Bir ışık bul. Yatak odasında, komodinin üstünde fener vardı...")

## "Tekrar Dene": karanlık bölümden, fenerle ve yatak odasından başla.
func _start_dark() -> void:
	_run_start = Time.get_ticks_msec() if _run_start == 0 else _run_start
	for l in get_tree().get_nodes_in_group("lamp"):
		LampControl.set_on(l, false)
	_go_dark()
	if is_instance_valid(_flashlight):
		_flashlight.queue_free()
	player.give_flashlight()
	hud.fade = 1.0
	hud.fade_to(0.0, 1.2)
	monster.activate(MonsterConfig.SPAWN)
	keys.spawn()
	_to_escape()
	hud.caption("Tekrar... sessiz ol.", 2.5)

# ---------- 3) Fener ----------
func _on_flashlight(_p: Node) -> void:
	_flashlight.queue_free()
	Sfx.play(self, "pickup", null)
	player.give_flashlight()
	hud.caption("Fener! (FENER ile aç / kapat — ışığı yaratığın yüzüne tutarsan korkabilir)", 4.0)
	if step == Step.FIND_LIGHT:
		_to_escape()

# ---------- 4) Anahtar ve kaçış ----------
func _to_escape() -> void:
	step = Step.ESCAPE
	if _door_known:
		_key_objective()
	else:
		hud.set_objective("Evden çık! Çıkış kapısı salonda.")

func _key_objective() -> void:
	hud.keys = keys.found
	if keys.found >= 3:
		hud.set_objective("Anahtar tamam! Çıkış kapısına git (salon).")
	else:
		hud.set_objective("Çıkış kapısının anahtarını bul: 3 parçası evin içine dağılmış.")

func _on_key(count: int) -> void:
	hud.keys = count
	hud.caption("Anahtar parçası bulundu! (%d/3)" % count, 2.5)
	if step == Step.ESCAPE:
		_key_objective()

func _on_all_keys() -> void:
	hud.caption("Parçaları birleştirdim... bu bir anahtar!", 3.0)

func _on_exit(_p: Node) -> void:
	if step == Step.DONE:
		return
	if keys.found >= 3 and step == Step.ESCAPE:
		_escape()
		return
	Sfx.play(self, "locked", HouseLayout.EXIT_DOOR + Vector3(0, 1, 0))
	if step == Step.ESCAPE:
		_door_known = true
		hud.caption("Kilitli! Anahtarı bulmam lazım...", 3.0)
		_key_objective()
	else:
		hud.caption("Kilitli. Gecenin bu saatinde nereye gideceğim ki?", 3.0)

func _escape() -> void:
	step = Step.DONE
	player.set_cinematic(true)
	monster.set_physics_process(false)
	Sfx.play(self, "locked", HouseLayout.EXIT_DOOR + Vector3(0, 1, 0), 2.0, 0.8)
	await _wait(0.6)
	Sfx.play(self, "door_open", HouseLayout.EXIT_DOOR + Vector3(0, 1, 0), 2.0)
	var door: Node3D = get_tree().get_first_node_in_group("exit_door")
	var tw := create_tween()
	tw.tween_property(door, "position", door.position + Vector3(-0.45, 0, -0.45), 0.9)
	tw.parallel().tween_property(door, "rotation_degrees:y", 90.0, 0.9)
	await hud.fade_to(1.0, 1.6).finished
	var secs := (Time.get_ticks_msec() - _run_start) / 1000
	checkpoint = false
	screens.show_mode("win", "Süre: %d:%02d" % [secs / 60, secs % 60])

## Test için: uyanışı atlayıp doğrudan yüz yıkama sahnesine geç.
func debug_wash() -> void:
	player.set_cinematic(false)
	hud.fade = 0.0
	step = Step.GO_WASH
	_on_wash(null)

## Test için: anahtarlar tamam, kapıdan kaç.
func debug_win() -> void:
	_start_dark()
	keys.found = 3
	_door_known = true
	await _wait(1.5)
	_on_exit(null)

## Test için: doğrudan karanlık bölüm.
func debug_dark() -> void:
	_start_dark()
