class_name HouseBuilder
## Evi HouseLayout verisinden kurar: zemin, tavan, duvarlar, kapı boşlukları, lambalar, çıkış kapısı.

const WALL_COLOR := Color(0.38, 0.35, 0.31)
const CEILING_COLOR := Color(0.22, 0.21, 0.20)

static func build(root: Node3D) -> Node3D:
	var house := Node3D.new()
	house.name = "House"
	root.add_child(house)
	for room in HouseLayout.ROOMS:
		var r: Rect2 = room["rect"]
		var c := Vector3(r.position.x + r.size.x / 2.0, -0.05, r.position.y + r.size.y / 2.0)
		Props.box(house, c, Vector3(r.size.x, 0.1, r.size.y), room["floor"])
		_ceiling_lamp(house, Vector3(c.x, HouseLayout.WALL_H, c.z))
	Props.box(house, Vector3(6, HouseLayout.WALL_H + 0.05, 5), Vector3(12.4, 0.1, 10.4), CEILING_COLOR)
	for w in HouseLayout.WALLS:
		_wall(house, w)
	_exit_door(house)
	HouseFurniture.build(house)
	return house

static func _wall(parent: Node3D, w: Dictionary) -> void:
	var cuts: Array = w["doors"].duplicate()
	cuts.sort_custom(func(a, b): return a[0] < b[0])
	var start: float = w["from"]
	for d in cuts:
		_segment(parent, w, start, d[0], 0.0, HouseLayout.WALL_H)
		_segment(parent, w, d[0], d[1], HouseLayout.DOOR_H, HouseLayout.WALL_H)
		start = d[1]
	_segment(parent, w, start, w["to"], 0.0, HouseLayout.WALL_H)

static func _segment(parent: Node3D, w: Dictionary, a: float, b: float, y0: float, y1: float) -> void:
	if b - a < 0.01:
		return
	var at: float = w["at"]
	var t := HouseLayout.WALL_T
	var mid := (a + b) / 2.0
	var y := (y0 + y1) / 2.0
	if w["axis"] == "z":
		Props.box(parent, Vector3(mid, y, at), Vector3(b - a, y1 - y0, t), WALL_COLOR)
	else:
		Props.box(parent, Vector3(at, y, mid), Vector3(t, y1 - y0, b - a), WALL_COLOR)

static func _exit_door(parent: Node3D) -> void:
	var n := Props.group_node(parent, HouseLayout.EXIT_DOOR, 0.0, "ExitDoor")
	n.add_to_group("exit_door")
	Props.box(n, Vector3(0, HouseLayout.DOOR_H / 2.0, 0), Vector3(1.0, HouseLayout.DOOR_H, 0.08), Color(0.28, 0.16, 0.09))
	Props.box(n, Vector3(0, 1.45, 0.05), Vector3(0.7, 0.6, 0.02), Color(0.22, 0.12, 0.07), false)
	Props.box(n, Vector3(0, 0.6, 0.05), Vector3(0.7, 0.7, 0.02), Color(0.22, 0.12, 0.07), false)
	Props.sphere(n, Vector3(0.38, 1.0, 0.08), 0.04, Color(0.75, 0.6, 0.25))
	# Yeşil "ÇIKIŞ" tabelası: karanlıkta yön bulmaya yardım eder.
	Props.box(n, Vector3(0, 2.3, 0.12), Vector3(0.45, 0.16, 0.03), Color(0.1, 0.9, 0.35), false, 2.5)

static func _ceiling_lamp(parent: Node3D, top: Vector3) -> void:
	var n := Props.group_node(parent, top, 0.0, "Lamp")
	n.add_to_group("lamp")
	Props.box(n, Vector3(0, -0.15, 0), Vector3(0.015, 0.3, 0.015), Color(0.1, 0.1, 0.1), false)
	Props.sphere(n, Vector3(0, -0.36, 0), 0.07, Color(1.0, 0.82, 0.55), 3.0)
	var light := OmniLight3D.new()
	light.position = Vector3(0, -0.45, 0)
	light.light_color = Color(1.0, 0.78, 0.5)
	light.light_energy = 0.55
	light.omni_range = 4.5
	light.shadow_enabled = false
	n.add_child(light)
