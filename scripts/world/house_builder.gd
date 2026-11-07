class_name HouseBuilder
## Evi HouseLayout verisinden kurar: dokulu zemin/tavan, duvar gövdesi (çarpışma),
## her odanın iç yüzüne kendi duvar kaplaması, süpürgelik, kapı kasaları, lambalar, çıkış kapısı.

const H := HouseLayout.WALL_H
const T := HouseLayout.WALL_T
const TRIM := Color(0.62, 0.58, 0.50)
const FRAME := Color(0.26, 0.16, 0.09)

static func build(root: Node3D) -> Node3D:
	var house := Node3D.new()
	house.name = "House"
	root.add_child(house)
	for room in HouseLayout.ROOMS:
		var r: Rect2 = room["rect"]
		var c := Vector3(r.position.x + r.size.x / 2.0, -0.05, r.position.y + r.size.y / 2.0)
		Props.box(house, c, Vector3(r.size.x, 0.1, r.size.y), Materials.room_floor(room["name"]))
		_room_skin(house, room["name"], r)
		_ceiling_lamp(house, Vector3(c.x, H, c.z))
	Props.box(house, Vector3(6, H + 0.05, 5), Vector3(12.4, 0.1, 10.4), Materials.surface("ceiling_interior", 2.0, Color(0.8, 0.78, 0.74)))
	var core := Materials.solid(Color(0.3, 0.28, 0.25), 0.9)
	for w in HouseLayout.WALLS:
		var cuts := HouseLayout.openings(w["axis"], w["at"])
		_split(house, w["axis"], w["at"], w["from"], w["to"], cuts, T, core, true)
		for d in w["doors"]:
			_door_frame(house, w["axis"], w["at"], d[0], d[1])
	WindowBuilder.build(house)
	for d in HouseLayout.DOORS:
		InteriorDoor.create(house, d)
	ExitDoor.build(house)
	HouseFurniture.build(house)
	return house

## Çizgi boyunca [a,b] aralığını boşluklarla (kapı [a,b] / pencere [a,b,y0,y1]) bölüp kutular koyar.
static func _split(p: Node3D, axis: String, at: float, a: float, b: float, cuts: Array, thick: float, m: Material, solid: bool, y_top: float = H, y_bottom: float = 0.0) -> void:
	var start := a
	for d in cuts:
		var d0: float = maxf(d[0], a)
		var d1: float = minf(d[1], b)
		if d1 <= a or d0 >= b:
			continue
		var oy0: float = d[2] if d.size() > 2 else 0.0
		var oy1: float = d[3] if d.size() > 2 else HouseLayout.DOOR_H
		_piece(p, axis, at, start, d0, y_bottom, y_top, thick, m, solid)
		_piece(p, axis, at, d0, d1, y_bottom, minf(oy0, y_top), thick, m, solid)
		_piece(p, axis, at, d0, d1, maxf(oy1, y_bottom), y_top, thick, m, solid)
		start = d1
	_piece(p, axis, at, start, b, y_bottom, y_top, thick, m, solid)

static func _piece(p: Node3D, axis: String, at: float, a: float, b: float, y0: float, y1: float, thick: float, m: Material, solid: bool) -> void:
	if b - a < 0.01 or y1 - y0 < 0.01:
		return
	var mid := (a + b) / 2.0
	var y := (y0 + y1) / 2.0
	if axis == "z":
		Props.box(p, Vector3(mid, y, at), Vector3(b - a, y1 - y0, thick), m, solid)
	else:
		Props.box(p, Vector3(at, y, mid), Vector3(thick, y1 - y0, b - a), m, solid)

## Odanın dört duvarının iç yüzüne kaplama + süpürgelik.
static func _room_skin(p: Node3D, room_name: String, r: Rect2) -> void:
	var wall_m := Materials.room_wall(room_name)
	var trim_m := Materials.solid(TRIM, 0.45)
	var x0 := r.position.x
	var x1 := r.end.x
	var z0 := r.position.y
	var z1 := r.end.y
	var o := T / 2.0
	var sides := [
		["z", z0, x0 + o, x1 - o, 1.0], ["z", z1, x0 + o, x1 - o, -1.0],
		["x", x0, z0 + o, z1 - o, 1.0], ["x", x1, z0 + o, z1 - o, -1.0],
	]
	for s in sides:
		var cuts := HouseLayout.openings(s[0], s[1])
		var at: float = s[1] + s[4] * (o + 0.006)
		_split(p, s[0], at, s[2], s[3], cuts, 0.012, wall_m, false)
		if room_name != "Banyo":
			var bt: float = s[1] + s[4] * (o + 0.012)
			_split(p, s[0], bt, s[2], s[3], cuts, 0.024, trim_m, false, 0.11)

## Kapı kasası: iki yan pervaz + üst pervaz (her iki yüzde) ve boşluk içi kaplama.
static func _door_frame(p: Node3D, axis: String, at: float, a: float, b: float) -> void:
	var m := Materials.solid(FRAME, 0.5)
	var dh := HouseLayout.DOOR_H
	var w := 0.07
	for side in [-1.0, 1.0]:
		var face: float = at + side * (T / 2.0 + 0.012)
		_piece(p, axis, face, a - w, a, 0.0, dh + w, 0.025, m, false)
		_piece(p, axis, face, b, b + w, 0.0, dh + w, 0.025, m, false)
		_piece(p, axis, face, a, b, dh, dh + w, 0.025, m, false)
	_piece(p, axis, at, a, a + 0.02, 0.0, dh, T + 0.02, m, false)
	_piece(p, axis, at, b - 0.02, b, 0.0, dh, T + 0.02, m, false)
	_piece(p, axis, at, a, b, dh - 0.02, dh, T + 0.02, m, false)

static func _ceiling_lamp(p: Node3D, top: Vector3) -> void:
	var n := Props.group_node(p, top, 0.0, "Lamp")
	n.add_to_group("lamp")
	Props.cyl(n, Vector3(0, -0.2, 0), 0.006, 0.4, Materials.solid(Color(0.05, 0.05, 0.05), 0.7), false)
	ModelLib.place(n, "pull_chain_light_socket", Vector3(0, -0.4, 0), 0.0, 1.0, false)
	Props.sphere(n, Vector3(0, -0.6, 0), 0.04, Color(1.0, 0.85, 0.6), 4.0)
	var light := OmniLight3D.new()
	light.position = Vector3(0, -0.7, 0)
	light.light_color = Color(1.0, 0.76, 0.48)
	light.light_energy = 0.6
	light.omni_range = 5.0
	light.omni_attenuation = 1.4
	light.shadow_enabled = false
	n.add_child(light)
