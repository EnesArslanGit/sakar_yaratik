class_name HideSpot
extends Node
## Yatak odasındaki dolaba saklanma. İçerideyken yaratık seni göremez; dolap kapağı aralığından bakarsın.
## Yaratık seni içeri girerken GÖRDÜYSE ve çok yakınsa yine de bulur.

var player: Player
var hud: Hud
var monster: Monster
var spot: Node3D
var _it: Interactable
var _outside := Vector3.ZERO
var _inside := false

func setup(p: Player, h: Hud, m: Monster) -> void:
	player = p
	hud = h
	monster = m
	spot = get_tree().get_first_node_in_group("hide_spot")
	_it = Interactable.attach(spot, "Dolaba saklan", Vector3(0.75, 1.2, 0))
	_it.used.connect(_toggle)

func _toggle(_p: Node) -> void:
	if _inside:
		_exit()
	else:
		_enter()

func _enter() -> void:
	var seen := monster != null and monster.sees_player and monster.global_position.distance_to(player.global_position) < 3.0
	_inside = true
	_outside = player.global_position
	_it.prompt = "Dolaptan çık"
	Sfx.play(self, "door_open", spot.global_position + Vector3(0, 1, 0), -4.0, 1.3)
	player.set_cinematic(true)
	var tw := player.create_tween().set_parallel()
	tw.tween_property(player, "global_position", spot.global_position + Vector3(0.62, -0.05, 0), 0.5)
	tw.tween_property(player, "rotation:y", deg_to_rad(-90), 0.5)
	tw.tween_property(player.camera, "rotation:x", 0.0, 0.5)
	await tw.finished
	player.hidden = true
	player.cinematic = false   # bakabilir ama yürüyemez (hidden)
	hud.hiding = true
	hud.caption("Nefesini tut...", 2.0)
	_it.set_meta("focus", player.camera.global_position + Vector3(0.5, 0, 0))
	if seen:
		await get_tree().create_timer(1.5).timeout
		if _inside:
			hud.caption("Seni gördü!", 1.5)
			_exit()

func _exit() -> void:
	_inside = false
	player.hidden = false
	hud.hiding = false
	_it.prompt = "Dolaba saklan"
	_it.set_meta("focus", spot.global_position + Vector3(0.75, 1.2, 0))
	Sfx.play(self, "door_open", spot.global_position + Vector3(0, 1, 0), -4.0, 1.1)
	player.set_cinematic(true)
	var tw := player.create_tween()
	tw.tween_property(player, "global_position", spot.global_position + Vector3(1.3, 0.05, 0), 0.45)
	await tw.finished
	player.set_cinematic(false)
