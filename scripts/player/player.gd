class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu: yürüme, bakma, koşma + dayanıklılık, fener (bulununca), etkileşim.
## Girdi: klavye/fare (test) + TouchControls (mobil, asıl kontrol).
## cinematic = true iken kontrol hikâyededir (kamera tween'lerle oynatılır).

signal interact_requested

const WALK_SPEED := 2.6
const RUN_SPEED := 4.6
const ACCEL := 12.0
const STAMINA_MAX := 100.0
const STAMINA_DRAIN := 22.0      # saniyede, koşarken
const STAMINA_REGEN := 14.0      # saniyede, koşmazken
const STAMINA_RESUME := 30.0     # tamamen bitince bu kadar dolmadan koşamaz
const GRAVITY := 9.8
const MOUSE_SENS := 0.0025
const TOUCH_SENS := 0.0045
const EYE_HEIGHT := 1.6
const REACH := 2.0               # etkileşim mesafesi (m)

var stamina := STAMINA_MAX
var exhausted := false
var is_running := false
var has_flashlight := false
var cinematic := false
var shake := 0.0
var target: Node3D = null        # şu an bakılan etkileşimli eşya
var controls: TouchControls
var camera: Camera3D
var flashlight: SpotLight3D
var _col: CollisionShape3D
var _bob_t := 0.0

func _ready() -> void:
	_col = CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.75
	_col.shape = cap
	_col.position.y = 0.875
	add_child(_col)
	camera = Camera3D.new()
	camera.position.y = EYE_HEIGHT
	camera.fov = 75.0
	camera.near = 0.05
	camera.cull_mask &= ~(1 << (Mirror.MIRROR_ONLY_LAYER - 1))
	add_child(camera)
	camera.make_current()
	flashlight = SpotLight3D.new()
	flashlight.position = Vector3(0.18, -0.2, 0.0)
	flashlight.light_color = Color(1.0, 0.93, 0.8)
	flashlight.light_energy = 3.0
	flashlight.spot_range = 14.0
	flashlight.spot_angle = 30.0
	flashlight.spot_attenuation = 0.8
	flashlight.shadow_enabled = true
	flashlight.shadow_bias = 0.08
	flashlight.shadow_normal_bias = 2.0
	flashlight.visible = false
	camera.add_child(flashlight)
	_mirror_body()

## Sadece aynada görünen basit beden (gölgemsi siluet).
func _mirror_body() -> void:
	var layer := 1 << (Mirror.MIRROR_ONLY_LAYER - 1)
	var shirt := Materials.solid(Color(0.24, 0.27, 0.33), 0.8)
	var skin := Materials.solid(Color(0.55, 0.42, 0.36), 0.6)
	var hair := Materials.solid(Color(0.06, 0.05, 0.04), 0.9)
	var body := Node3D.new()
	body.position.z = 0.06
	add_child(body)
	var torso := _capsule(body, Vector3(0, 1.13, 0), 0.19, 0.72, shirt)
	torso.scale = Vector3(1.0, 1.0, 0.55)
	_capsule(body, Vector3(0, 1.4, 0), 0.085, 0.5, shirt).rotation_degrees.z = 90
	for sx in [-1.0, 1.0]:
		var arm := _capsule(body, Vector3(sx * 0.255, 1.1, 0), 0.055, 0.62, shirt)
		arm.rotation_degrees.z = sx * 4.0
		Props.sphere(body, Vector3(sx * 0.27, 0.77, 0), 0.045, skin)
	Props.cyl(body, Vector3(0, 1.5, 0), 0.055, 0.12, skin, false)
	var head := Props.sphere(body, Vector3(0, 1.63, -0.01), 0.105, skin)
	head.scale = Vector3(0.9, 1.15, 1.0)
	var hair_m := Props.sphere(body, Vector3(0, 1.675, 0.015), 0.104, hair)
	hair_m.scale = Vector3(0.95, 0.85, 1.0)
	for mi in body.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).layers = layer
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Yansımadaki yüzü okunur kılan hafif dolgu ışığı (sadece aynadaki bedeni aydınlatır).
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 1.6, -0.9)
	fill.light_energy = 0.18
	fill.omni_range = 1.6
	fill.light_color = Color(1.0, 0.9, 0.8)
	fill.light_cull_mask = layer
	add_child(fill)

func _capsule(parent: Node3D, pos: Vector3, r: float, h: float, m: Material) -> MeshInstance3D:
	var cm := CapsuleMesh.new()
	cm.radius = r
	cm.height = h
	cm.radial_segments = 24
	cm.rings = 8
	var mi := MeshInstance3D.new()
	mi.mesh = cm
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)
	return mi

func set_controls(c: TouchControls) -> void:
	controls = c
	controls.flashlight_pressed.connect(toggle_flashlight)
	controls.interact_pressed.connect(_on_interact)

func give_flashlight() -> void:
	has_flashlight = true
	flashlight.visible = true
	if controls:
		controls.show_flash = true
		controls.flash_on = true

func toggle_flashlight() -> void:
	if not has_flashlight or cinematic:
		return
	flashlight.visible = not flashlight.visible
	if controls:
		controls.flash_on = flashlight.visible

func set_cinematic(on: bool) -> void:
	cinematic = on
	_col.disabled = on
	velocity = Vector3.ZERO
	if controls:
		controls.move_vector = Vector2.ZERO

func _on_interact() -> void:
	interact_requested.emit()
	if not cinematic and target and target.has_method("interact"):
		target.interact(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var cap := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if cap else Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not cinematic:
			_look(event.relative * MOUSE_SENS)
	elif event.is_action_pressed("flashlight"):
		toggle_flashlight()
	elif event.is_action_pressed("interact"):
		_on_interact()
	elif event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _look(rad: Vector2) -> void:
	rotate_y(-rad.x)
	camera.rotation.x = clampf(camera.rotation.x - rad.y, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	_apply_shake(delta)
	if cinematic:
		target = null
		return
	if controls:
		_look(controls.consume_look() * TOUCH_SENS)
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if controls:
		input += controls.move_vector
	input = input.limit_length(1.0)
	var moving := input.length() > 0.1
	var want_run := Input.is_action_pressed("run") or (controls != null and controls.run_held)
	_update_stamina(delta, want_run and moving)
	var speed := RUN_SPEED if is_running else WALK_SPEED
	var dir := (transform.basis * Vector3(input.x, 0, input.y))
	var goal := dir * speed
	velocity.x = move_toward(velocity.x, goal.x, ACCEL * delta)
	velocity.z = move_toward(velocity.z, goal.z, ACCEL * delta)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	_head_bob(delta)
	target = _find_target()

## Bakış yönüne en yakın, menzildeki etkileşimli eşya.
func _find_target() -> Node3D:
	var best: Node3D = null
	var best_score := 0.0
	var eye := camera.global_position
	var fwd := -camera.global_basis.z
	for n in get_tree().get_nodes_in_group("interactable"):
		var node := n as Node3D
		if node.get_prompt() == "":
			continue
		var focus: Vector3 = node.get_meta("focus", node.global_position)
		var to := focus - eye
		var d := to.length()
		if d > REACH:
			continue
		var score := fwd.dot(to / d)
		if score > 0.8 and score > best_score:
			best = node
			best_score = score
	return best

func _update_stamina(delta: float, trying: bool) -> void:
	if exhausted and stamina >= STAMINA_RESUME:
		exhausted = false
	is_running = trying and not exhausted and stamina > 0.0
	if is_running:
		stamina = maxf(stamina - STAMINA_DRAIN * delta, 0.0)
		if stamina <= 0.0:
			exhausted = true
	else:
		stamina = minf(stamina + STAMINA_REGEN * delta, STAMINA_MAX)

func _head_bob(delta: float) -> void:
	var hspeed := Vector2(velocity.x, velocity.z).length()
	if hspeed > 0.3:
		_bob_t += delta * hspeed * 2.4
	camera.position.y = lerpf(camera.position.y, EYE_HEIGHT + sin(_bob_t) * 0.035 * minf(hspeed / WALK_SPEED, 1.5), 0.3)

func _apply_shake(delta: float) -> void:
	shake = maxf(shake - delta * 1.5, 0.0)
	camera.h_offset = randf_range(-1, 1) * shake * 0.05
	camera.v_offset = randf_range(-1, 1) * shake * 0.05
