class_name InteriorDoor
extends Node3D
## Menteşeli iç kapı. KULLAN ile açılır/kapanır. locked = true ise açılmaz.
## Etkileşim sistemi: "interactable" grubu, get_prompt() ve interact(player).

const OPEN_ANGLE := 100.0

var locked := false
var is_open := false
var _closed_yaw := 0.0
var _open_yaw := 0.0
var _hinge: Node3D
var _tween: Tween

## d: HouseLayout.DOORS kaydı.
static func create(parent: Node3D, d: Dictionary) -> InteriorDoor:
	var door := InteriorDoor.new()
	door.name = "Door"
	parent.add_child(door)
	door._build(d)
	return door

func _build(d: Dictionary) -> void:
	add_to_group("interactable")
	var a: float = d["a"]
	var b: float = d["b"]
	var at: float = d["at"]
	var hinge_at := a if d["hinge"] == "a" else b
	var dir := Vector3.ZERO
	var normal := Vector3.ZERO
	if d["axis"] == "z":
		_hinge_pos(Vector3(hinge_at, 0, at))
		dir = Vector3(signf(b - a) * (1.0 if d["hinge"] == "a" else -1.0), 0, 0)
		normal = Vector3(0, 0, d["swing"])
	else:
		_hinge_pos(Vector3(at, 0, hinge_at))
		dir = Vector3(0, 0, 1.0 if d["hinge"] == "a" else -1.0)
		normal = Vector3(d["swing"], 0, 0)
	# Kanat yerel +X boyunca uzanır; kapalıyken X ekseni dir'e bakmalı.
	_closed_yaw = atan2(-dir.z, dir.x)
	var test := dir.rotated(Vector3.UP, PI / 2.0)
	_open_yaw = _closed_yaw + deg_to_rad(OPEN_ANGLE) * (1.0 if test.dot(normal) > 0.0 else -1.0)
	_hinge.rotation.y = _closed_yaw
	_leaf(absf(b - a))
	set_meta("focus", _hinge.position + dir * absf(b - a) * 0.5 + Vector3(0, 1.1, 0))

func _hinge_pos(p: Vector3) -> void:
	_hinge = Node3D.new()
	_hinge.position = p
	add_child(_hinge)

func _leaf(width: float) -> void:
	var w := width - 0.03
	var dh := HouseLayout.DOOR_H - 0.03
	var body := AnimatableBody3D.new()
	body.sync_to_physics = false
	_hinge.add_child(body)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(w, dh, 0.05)
	cs.shape = shape
	cs.position = Vector3(w / 2.0 + 0.015, dh / 2.0 + 0.01, 0)
	body.add_child(cs)
	var wood := Materials.surface("wood_floor_worn", 1.0, Color(0.55, 0.38, 0.26))
	var panel := Materials.surface("wood_floor_worn", 1.0, Color(0.45, 0.3, 0.2))
	var brass := Materials.solid(Color(0.78, 0.6, 0.3), 0.3, 1.0)
	var cx := w / 2.0 + 0.015
	Props.box(body, Vector3(cx, dh / 2.0 + 0.01, 0), Vector3(w, dh, 0.045), wood, false)
	for side in [-1.0, 1.0]:
		for row in [[0.2, 0.9], [1.05, 1.9]]:
			Props.box(body, Vector3(cx, (row[0] + row[1]) / 2.0, side * 0.025), Vector3(w - 0.2, row[1] - row[0], 0.01), panel, false)
		var knob := Props.sphere(body, Vector3(w - 0.07, 1.0, side * 0.06), 0.028, brass)
		knob.scale = Vector3(1, 1, 0.8)
		Props.cyl(body, Vector3(w - 0.07, 1.0, side * 0.035), 0.03, 0.015, brass, false).rotation_degrees.x = 90

func get_prompt() -> String:
	if _tween and _tween.is_running():
		return ""
	return "Kapıyı kapat" if is_open else "Kapıyı aç"

func interact(_player: Node) -> void:
	if locked:
		Sfx.play(self, "locked", get_meta("focus"))
		return
	is_open = not is_open
	Sfx.play(self, "door_open" if is_open else "door_close", get_meta("focus"))
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_hinge, "rotation:y", _open_yaw if is_open else _closed_yaw, 0.9 if is_open else 0.6)
