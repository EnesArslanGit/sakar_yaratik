class_name Monster
extends CharacterBody3D
## Yaratığın beyni (durum makinesi): DEVRİYE → ŞÜPHE (ses) → KOVALAMA (görünce) → ARAMA → DEVRİYE.
## SAKARLIK durumunu MonsterClumsy yönetir. Yakalamayı CatchSequence oynatır.
## Tüm sayılar MonsterConfig'te.

signal caught(monster: Monster)

enum State { INACTIVE, PATROL, SUSPICIOUS, CHASE, SEARCH, CLUMSY, CATCH }
const C := preload("res://scripts/monster/monster_config.gd")

var state := State.INACTIVE
var prev_state := State.PATROL
var player: Player
var body: MonsterBody
var agent: NavigationAgent3D
var clumsy: MonsterClumsy
var last_seen := Vector3.ZERO
var sees_player := false
var debug_info := ""

var _target := Vector3.ZERO
var _speed := 0.0
var _timer := 0.0
var _lose := 0.0
var _grace := 0.0
var _patrol_i := 0
var _step_t := 0.0
var _growl_t := 5.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 2.0
	cs.shape = cap
	cs.position.y = 1.0
	add_child(cs)
	body = MonsterBody.new()
	add_child(body)
	agent = NavigationAgent3D.new()
	agent.path_desired_distance = 0.5
	agent.target_desired_distance = 0.6
	agent.radius = 0.35
	agent.height = 1.6
	add_child(agent)
	clumsy = MonsterClumsy.new()
	clumsy.monster = self
	add_child(clumsy)
	NoiseBus.add(self)
	visible = false
	set_physics_process(false)

func _exit_tree() -> void:
	NoiseBus.remove(self)

func activate(at: Vector3) -> void:
	global_position = at
	visible = true
	_grace = C.START_GRACE
	set_physics_process(true)
	_go_patrol()

# ---------------- Durumlar ----------------
func _go_patrol() -> void:
	state = State.PATROL
	_speed = C.PATROL_SPEED
	_next_patrol_point()

func _next_patrol_point() -> void:
	var tries := 0
	while tries < 5:
		_patrol_i = randi() % C.PATROL_POINTS.size()
		var p: Vector2 = C.PATROL_POINTS[_patrol_i]
		_target = Vector3(p.x, 0, p.y)
		if _target.distance_to(global_position) > 2.0:
			break
		tries += 1
	agent.target_position = _target

func _go_chase() -> void:
	if state != State.CHASE:
		Sfx.play(self, "growl", global_position + Vector3(0, 2, 0), 2.0, 0.9)
	state = State.CHASE
	_speed = C.CHASE_SPEED
	_lose = 0.0

func _go_search() -> void:
	state = State.SEARCH
	_speed = C.SEARCH_SPEED
	_timer = C.SEARCH_TIME
	agent.target_position = last_seen

func hear(pos: Vector3, radius: float, _source: String) -> void:
	if state in [State.INACTIVE, State.CLUMSY, State.CATCH, State.CHASE]:
		return
	if pos.distance_to(global_position) > radius:
		return
	state = State.SUSPICIOUS
	_speed = C.SUSPICIOUS_SPEED
	_timer = C.SUSPICIOUS_LOOK_TIME
	agent.target_position = pos

## Sakarlık başlarken/bitince MonsterClumsy çağırır.
func enter_clumsy() -> void:
	if state != State.CLUMSY:
		prev_state = state
	state = State.CLUMSY
	velocity = Vector3.ZERO

func exit_clumsy() -> void:
	if state == State.CLUMSY:
		state = prev_state
		if state == State.CHASE:
			_speed = C.CHASE_SPEED

# ---------------- Döngü ----------------
func _physics_process(delta: float) -> void:
	_grace = maxf(_grace - delta, 0.0)
	if state == State.CATCH or state == State.CLUMSY:
		_animate(0.0)
		return
	sees_player = _can_see_player()
	if sees_player:
		last_seen = player.global_position
		_go_chase()
	match state:
		State.PATROL:
			if agent.is_navigation_finished():
				_next_patrol_point()
		State.SUSPICIOUS:
			if agent.is_navigation_finished():
				_speed = 0.0
				_timer -= delta
				body.rotation.y += delta * 1.5
				if _timer <= 0.0:
					_go_patrol()
		State.CHASE:
			agent.target_position = last_seen if not sees_player else player.global_position
			if not sees_player:
				_lose += delta
				if _lose > C.LOSE_SIGHT_TIME:
					_go_search()
			_growl_t -= delta
			if _growl_t <= 0.0:
				_growl_t = randf_range(5.0, 9.0)
				Sfx.play(self, "growl", global_position + Vector3(0, 2, 0), 0.0, randf_range(0.8, 1.05))
			if _grace <= 0.0 and not player.hidden and global_position.distance_to(player.global_position) < C.CATCH_DISTANCE:
				state = State.CATCH
				velocity = Vector3.ZERO
				caught.emit(self)
				return
		State.SEARCH:
			_timer -= delta
			if agent.is_navigation_finished():
				agent.target_position = last_seen + Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5))
			if _timer <= 0.0:
				_go_patrol()
	_move(delta)
	clumsy.tick(delta)

func _move(delta: float) -> void:
	var v := Vector3.ZERO
	if not agent.is_navigation_finished() and _speed > 0.0:
		var next := agent.get_next_path_position()
		var dir := next - global_position
		dir.y = 0.0
		if dir.length() > 0.05:
			v = dir.normalized() * _speed
	velocity = velocity.lerp(v, clampf(delta * 6.0, 0.0, 1.0))
	velocity.y = 0.0
	move_and_slide()
	global_position.y = 0.0
	var flat := Vector3(velocity.x, 0, velocity.z)
	if flat.length() > 0.2:
		var yaw := atan2(-flat.x, -flat.z)
		rotation.y = lerp_angle(rotation.y, yaw, clampf(delta * C.TURN_SPEED, 0.0, 1.0))
		body.rotation.y = lerp_angle(body.rotation.y, 0.0, clampf(delta * 4.0, 0.0, 1.0))
	_animate(flat.length())
	_footsteps(delta, flat.length())
	_open_doors()

func _animate(spd: float) -> void:
	if state == State.CLUMSY or state == State.CATCH:
		return
	if spd < 0.15:
		body.play("Idle")
	elif spd < 2.4:
		body.play("Walk", spd / 1.35)
	else:
		body.play("Jog_Fwd", spd / 3.0)

func _footsteps(delta: float, spd: float) -> void:
	if spd < 0.3:
		return
	_step_t -= delta
	if _step_t <= 0.0:
		_step_t = clampf(0.95 / spd, 0.28, 0.7)
		Sfx.play(self, "step_heavy", global_position, -4.0 if spd > 2.4 else -9.0, randf_range(0.55, 0.7))

func _open_doors() -> void:
	for d in get_tree().get_nodes_in_group("door"):
		var door := d as InteriorDoor
		if not door.is_open and not door.locked:
			var f: Vector3 = door.get_meta("focus")
			if Vector2(f.x - global_position.x, f.z - global_position.z).length() < 1.2:
				door.slam_open()

# ---------------- Duyular ----------------
func _can_see_player() -> bool:
	if player == null or player.hidden:
		return false
	var eye := global_position + Vector3(0, 2.0, 0)
	var target := player.camera.global_position
	var to := target - eye
	var dist := to.length()
	var rng := C.SIGHT_RANGE_LIGHT if player.flashlight.visible else C.SIGHT_RANGE_DARK
	if dist > rng:
		return false
	var fwd := -global_basis.z
	var flat := Vector3(to.x, 0, to.z).normalized()
	if dist > C.CLOSE_SENSE and rad_to_deg(fwd.angle_to(flat)) > C.SIGHT_FOV_DEG * 0.5:
		return false
	var q := PhysicsRayQueryParameters3D.create(eye, target, 1 | 2, [get_rid(), player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()

## Yakalama sırasında tökezleyip düştükten sonra kalkınca.
func after_stumble() -> void:
	_grace = 1.5
	_go_chase()
	last_seen = player.global_position

func state_name() -> String:
	return State.keys()[state]
