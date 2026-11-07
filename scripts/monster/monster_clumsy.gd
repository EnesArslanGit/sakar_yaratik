class_name MonsterClumsy
extends Node
## Yaratığın 7 sakarlığı. Her biri: kısa hareket + ses + ekranda yön gösteren gürültü işareti.
## Aralarında en az CLUMSY_MIN_GAP sn olur. Olay sırasında yaratık durur (monster.enter_clumsy).
## 1 Ayağına takılma  2 Kapıya kafa çarpma  3 Eşya devirme  4 Kapıda sıkışma
## 5 Halıda kayma  6 Hapşırma  7 Fenerle aydınlatılınca kendi gölgesinden korkma

const C := preload("res://scripts/monster/monster_config.gd")

var monster: Monster
var gap := 4.0                     # sonraki olaya kadar kalan en az süre
var busy := false
var last_event := ""
var _door_cool := {}               # kapı -> bekleme
var _rug_inside := false
var _light_on_face := 0.0

func tick(delta: float) -> void:
	gap = maxf(gap - delta, 0.0)
	for k in _door_cool.keys():
		_door_cool[k] -= delta
		if _door_cool[k] <= 0.0:
			_door_cool.erase(k)
	if busy:
		return
	_check_shadow(delta)
	if gap > 0.0 or busy:
		return
	var moving := monster.velocity.length() > 0.5
	var chasing := monster.state == Monster.State.CHASE
	if _check_door(chasing):
		return
	if moving and _check_rug():
		return
	if moving and _check_knock():
		return
	var trip_p := (C.TRIP_CHANCE_CHASE if chasing else C.TRIP_CHANCE_PATROL) * delta
	if moving and randf() < trip_p:
		_run("trip")
	elif randf() < C.SNEEZE_CHANCE * delta:
		_run("sneeze")

# ---------- Tetikleyiciler ----------
func _check_door(chasing: bool) -> bool:
	for d in monster.get_tree().get_nodes_in_group("door"):
		var f: Vector3 = d.get_meta("focus")
		var dist := Vector2(f.x - monster.global_position.x, f.z - monster.global_position.z).length()
		if dist < 0.55 and not _door_cool.has(d):
			_door_cool[d] = 4.0
			if chasing and randf() < C.DOOR_STUCK_CHANCE:
				_run("stuck")
				return true
			if randf() < C.DOOR_BONK_CHANCE:
				_run("bonk")
				return true
	return false

func _check_rug() -> bool:
	var on := false
	for r in monster.get_tree().get_nodes_in_group("rug"):
		var s: Vector2 = r.get_meta("size")
		var lp: Vector3 = (r as Node3D).global_position
		if absf(monster.global_position.x - lp.x) < s.x / 2.0 and absf(monster.global_position.z - lp.z) < s.y / 2.0:
			on = true
	var entered := on and not _rug_inside
	_rug_inside = on
	if entered and randf() < C.SLIP_CHANCE:
		_run("slip")
		return true
	return false

func _check_knock() -> bool:
	for b in monster.get_tree().get_nodes_in_group("breakable"):
		var n := b as Node3D
		if n.has_meta("broken"):
			continue
		var p := n.global_position
		if Vector2(p.x - monster.global_position.x, p.z - monster.global_position.z).length() < 0.9:
			n.set_meta("broken", true)
			if randf() < C.KNOCK_CHANCE:
				_knock(n)
				return true
	return false

func _check_shadow(delta: float) -> void:
	var pl := monster.player
	if pl == null or not pl.flashlight.visible or gap > 0.0:
		_light_on_face = 0.0
		return
	var head := monster.global_position + Vector3(0, 2.0, 0)
	var to := head - pl.camera.global_position
	var lit := to.length() < 9.0 and (-pl.camera.global_basis.z).angle_to(to.normalized()) < deg_to_rad(14.0)
	_light_on_face = _light_on_face + delta if lit and monster.sees_player else 0.0
	if _light_on_face > C.SHADOW_SCARE_TIME:
		_light_on_face = 0.0
		_run("shadow")

# ---------- Olaylar ----------
func _run(kind: String) -> void:
	busy = true
	last_event = kind
	monster.enter_clumsy()
	var b := monster.body
	var pos := monster.global_position
	_ping(pos)
	match kind:
		"trip":
			b.play("Death01", 1.4, 0.1, true)
			await _wait(0.45)
			Sfx.play(monster, "thud", pos, 4.0, 0.7)
			await _wait(1.4)
			b.play_backwards("Death01", 1.3)
			await _wait(b.anim_length("Death01") / 1.3)
			b.play("Hit_Chest", 1.4, 0.1, true)
			await _wait(0.6)
		"bonk":
			Sfx.play(monster, "donk", pos + Vector3(0, 2.1, 0), 6.0, 0.8)
			b.play("Hit_Head", 1.0, 0.05, true)
			monster.player.shake = maxf(monster.player.shake, 0.15)
			await _wait(randf_range(1.5, 2.2))
		"stuck":
			Sfx.play(monster, "door_open", pos, 2.0, 0.6)
			b.play("Push", 1.6, 0.1)
			await _wait(2.4)
			Sfx.play(monster, "pop", pos, 3.0, 1.0)
			b.play("Jump_Land", 1.2, 0.05, true)
			var tw := monster.create_tween()
			tw.tween_property(monster, "global_position", pos - monster.global_basis.z * 0.8, 0.3)
			await _wait(0.7)
		"slip":
			Sfx.play(monster, "squeak", pos, 0.0, 1.0)
			b.play("Swim_Idle", 2.2, 0.05)
			var tw2 := monster.create_tween()
			tw2.tween_property(monster, "global_position", pos - monster.global_basis.z * 0.9, 1.1).set_ease(Tween.EASE_OUT)
			await _wait(1.3)
			Sfx.play(monster, "thud", pos, 0.0, 0.8)
			b.play("Jump_Land", 1.0, 0.1, true)
			await _wait(0.9)
		"sneeze":
			b.play("Idle", 1.0)
			var tw3 := monster.create_tween()
			tw3.tween_property(b.mod, "extra_hunch", -14.0, 0.9)
			tw3.tween_property(b.mod, "extra_hunch", 24.0, 0.12)
			await _wait(1.0)
			Sfx.play(monster, "sneeze", pos + Vector3(0, 2, 0), 8.0, 0.6)
			b.play("Hit_Chest", 1.2, 0.05, true)
			await _wait(0.5)
			b.mod.extra_hunch = 0.0
			b.play("Jump", 1.3, 0.05, true)
			await _wait(1.0)
		"shadow":
			Sfx.play(monster, "whimper", pos + Vector3(0, 2, 0), 2.0, 1.5)
			b.play("Hit_Chest", 1.0, 0.05, true)
			var back := pos + monster.global_basis.z * 1.2
			var tw4 := monster.create_tween()
			tw4.tween_property(monster, "global_position", back, 0.35)
			await _wait(0.4)
			b.play("Crouch_Idle", 1.0)
			await _wait(randf_range(1.8, 2.4))
	busy = false
	gap = C.CLUMSY_MIN_GAP
	monster.exit_clumsy()

func _knock(obj: Node3D) -> void:
	busy = true
	last_event = "knock"
	monster.enter_clumsy()
	_ping(obj.global_position)
	monster.body.play("Interact", 1.6, 0.1, true)
	await _wait(0.35)
	var fall_to := obj.global_position
	fall_to.y = 0.02
	var side := Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
	var tw := obj.create_tween().set_parallel()
	tw.tween_property(obj, "global_position", fall_to + side, 0.45).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(obj, "rotation_degrees", Vector3(90, randf_range(0, 360), 0), 0.45)
	await tw.finished
	Sfx.play(monster, "glass", obj.global_position, 6.0, randf_range(0.9, 1.1))
	obj.scale = Vector3(1, 0.35, 1)
	monster.body.play("Idle", 1.0)
	for i in 3:
		var t2 := monster.create_tween()
		t2.tween_property(monster.body, "rotation:y", randf_range(-1.2, 1.2), 0.3)
		await _wait(0.45)
	busy = false
	gap = C.CLUMSY_MIN_GAP
	monster.exit_clumsy()

func _ping(pos: Vector3) -> void:
	var hud := monster.get_tree().get_first_node_in_group("hud")
	if hud:
		hud.ping(pos)

func _wait(s: float) -> void:
	await monster.get_tree().create_timer(s).timeout
