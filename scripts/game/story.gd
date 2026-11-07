class_name Story
extends Node
## Giriş hikâyesi:
## 1) 03:07, alarm çalar, yatakta uyanırsın → KULLAN ile alarmı kapat, kalkarsın.
## 2) Banyoya gidip yüzünü yıka → aynada yaratık belirir → pencereler kararır, lambalar patlar.
## 3) Karanlıkta komodindeki feneri bul.
## 4) Çıkış kapısına git → kilitli, anahtar lazım (anahtar parçaları Aşama 4'te).

enum Step { WAKE, GO_WASH, WASHING, FIND_LIGHT, ESCAPE }

var step := Step.WAKE
var player: Player
var hud: Hud
var env: Environment
var _alarm: Node
var _wake_ready := false
var _sink: Node3D
var _sink_it: Interactable
var _mirror: Mirror
var _flashlight: Node3D

func setup(p: Player, h: Hud, e: Environment) -> void:
	player = p
	hud = h
	env = e
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

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func _tween() -> Tween:
	return create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ---------- 1) Uyanış ----------
func start() -> void:
	var clock: Node3D = get_tree().get_first_node_in_group("alarm_clock")
	player.set_cinematic(true)
	player.global_position = Vector3(4.3, -0.72, 9.3)
	player.rotation.y = 0.0
	player.camera.rotation.x = deg_to_rad(72)
	hud.fade = 1.0
	_alarm = Sfx.play(self, "alarm", clock.global_position + Vector3(0, 0.1, 0), 2.0)
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
	Sfx.play(self, "locked", null, -10.0)
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

# ---------- 2) Banyo ve ayna ----------
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
	if player.has_flashlight:
		_to_escape()
	else:
		step = Step.FIND_LIGHT
		hud.caption("Hiçbir şey göremiyorum!", 3.0)
		hud.set_objective("Bir ışık bul. Yatak odasında, komodinin üstünde fener vardı...")

func _scare() -> void:
	var face := ScareFace.create(get_tree().current_scene)
	face.global_position = player.global_position + Vector3(-0.55, 1.78, 0.42)
	face.rotation_degrees.y = 75.0
	Sfx.play(self, "sting", null, 2.0)
	player.shake = 1.2
	var lunge := create_tween()
	lunge.tween_property(face, "global_position", face.global_position + Vector3(0.3, -0.05, -0.15), 1.0).set_ease(Tween.EASE_IN)
	await _wait(1.1)
	var tw := _tween()
	tw.tween_property(player, "rotation:y", deg_to_rad(90), 0.35)
	await tw.finished
	face.queue_free()
	await _wait(0.8)
	hud.caption("Ne... neydi o?!", 2.5)

func _blackout() -> void:
	await LampControl.flicker_all(self, 1.8)
	WindowBuilder.set_all_dark(get_tree())
	_mirror.set_dark(true)
	env.ambient_light_energy = 0.1
	env.ambient_light_color = Color(0.35, 0.4, 0.6)
	player.shake = 0.5
	await LampControl.burst_all(self)
	await _wait(0.6)

# ---------- 3) Fener ----------
func _on_flashlight(_p: Node) -> void:
	_flashlight.queue_free()
	Sfx.play(self, "pickup", null)
	player.give_flashlight()
	hud.caption("Fener! (FENER ile aç / kapat)", 3.0)
	if step == Step.FIND_LIGHT:
		_to_escape()

# ---------- 4) Kaçış ----------
func _to_escape() -> void:
	step = Step.ESCAPE
	hud.set_objective("Evden çık! Çıkış kapısı salonda.")

func _on_exit(_p: Node) -> void:
	Sfx.play(self, "locked", HouseLayout.EXIT_DOOR + Vector3(0, 1, 0))
	if step == Step.ESCAPE:
		hud.caption("Kilitli! Anahtarı bulmam lazım...", 3.0)
		hud.set_objective("Çıkış kapısının anahtarını bul.")
	else:
		hud.caption("Kilitli. Gecenin bu saatinde nereye gideceğim ki?", 3.0)

## Test için: uyanışı atlayıp doğrudan yüz yıkama sahnesine geç.
func debug_wash() -> void:
	player.set_cinematic(false)
	hud.fade = 0.0
	step = Step.GO_WASH
	_on_wash(null)
