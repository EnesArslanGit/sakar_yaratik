class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu: yürüme, bakma, koşma + dayanıklılık, fener.
## Girdi: klavye/fare (test) + TouchControls (mobil, asıl kontrol).

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

var stamina := STAMINA_MAX
var exhausted := false
var is_running := false
var controls: TouchControls
var camera: Camera3D
var flashlight: SpotLight3D
var _bob_t := 0.0

func _ready() -> void:
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.75
	col.shape = cap
	col.position.y = 0.875
	add_child(col)
	camera = Camera3D.new()
	camera.position.y = EYE_HEIGHT
	camera.fov = 75.0
	camera.near = 0.05
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
	camera.add_child(flashlight)

func set_controls(c: TouchControls) -> void:
	controls = c
	controls.flashlight_pressed.connect(toggle_flashlight)
	controls.interact_pressed.connect(func(): interact_requested.emit())
	controls.flash_on = flashlight.visible

func toggle_flashlight() -> void:
	flashlight.visible = not flashlight.visible
	if controls:
		controls.flash_on = flashlight.visible
		controls.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var cap := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if cap else Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * MOUSE_SENS)
	elif event.is_action_pressed("flashlight"):
		toggle_flashlight()
	elif event.is_action_pressed("interact"):
		interact_requested.emit()
	elif event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _look(rad: Vector2) -> void:
	rotate_y(-rad.x)
	camera.rotation.x = clampf(camera.rotation.x - rad.y, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
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
	var target := dir * speed
	velocity.x = move_toward(velocity.x, target.x, ACCEL * delta)
	velocity.z = move_toward(velocity.z, target.z, ACCEL * delta)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	_head_bob(delta)

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
