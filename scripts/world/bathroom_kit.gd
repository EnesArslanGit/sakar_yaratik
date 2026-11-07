class_name BathroomKit
## Porselen banyo eşyaları (pürüzsüz, içi oyuk): klozet, lavabo, havluluk, tuvalet kâğıdı.
## pos = zemindeki merkez, rot = Y derece. Arkası yerel -Z, önü +Z.

static func porcelain() -> StandardMaterial3D:
	return Materials.solid(Color(0.93, 0.93, 0.91), 0.08)

static func chrome() -> StandardMaterial3D:
	return Materials.solid(Color(0.85, 0.85, 0.87), 0.2, 0.5)

static func _pv(points: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(Vector2(p[0], p[1]))
	return out

static func toilet(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Toilet")
	var c := porcelain()
	# Oyuk hazne: dış gövde aşağıdan kenara, sonra içe ve dibe.
	var bowl := _pv([[0.0, 0.0], [0.13, 0.0], [0.135, 0.04], [0.12, 0.12], [0.13, 0.2], [0.165, 0.28], [0.19, 0.35], [0.2, 0.39], [0.195, 0.41], [0.175, 0.41], [0.16, 0.37], [0.13, 0.3], [0.09, 0.24], [0.05, 0.2], [0.0, 0.19]])
	Lathe.add(n, bowl, Vector3(0, 0, 0.07), c, 1.28)
	var water := Props.cyl(n, Vector3(0, 0.255, 0.07), 0.105, 0.004, Materials.solid(Color(0.6, 0.68, 0.66), 0.03), false)
	water.scale = Vector3(1, 1, 1.28)
	# Klozet kapağı/oturağı: yassı halka.
	var seat := FurnitureKit.torus(n, Vector3(0, 0.425, 0.07), 0.135, 0.205, Materials.solid(Color(0.97, 0.97, 0.95), 0.25))
	seat.scale = Vector3(1, 0.22, 1.28)
	# Açık kapak arkada dik duruyor.
	var lid := Props.cyl(n, Vector3(0, 0.62, -0.13), 0.2, 0.025, Materials.solid(Color(0.97, 0.97, 0.95), 0.25), false)
	lid.rotation_degrees.x = 80
	lid.scale = Vector3(1, 1, 1.25)
	# Rezervuar.
	Props.box(n, Vector3(0, 0.36, -0.2), Vector3(0.2, 0.2, 0.12), c, false)
	Props.box(n, Vector3(0, 0.66, -0.235), Vector3(0.42, 0.4, 0.17), c, false)
	Props.box(n, Vector3(0, 0.875, -0.235), Vector3(0.45, 0.035, 0.2), c, false)
	Props.cyl(n, Vector3(0, 0.897, -0.235), 0.025, 0.012, chrome(), false)
	var lever := Props.box(n, Vector3(-0.17, 0.78, -0.14), Vector3(0.09, 0.015, 0.015), chrome(), false)
	lever.rotation_degrees.y = 10
	Props.collider(n, Vector3(0, 0.45, -0.02), Vector3(0.46, 0.9, 0.64))
	return n

static func sink(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Sink")
	var c := porcelain()
	var pedestal := _pv([[0.0, 0.0], [0.11, 0.0], [0.11, 0.02], [0.085, 0.06], [0.065, 0.25], [0.06, 0.5], [0.075, 0.66], [0.11, 0.72], [0.0, 0.72]])
	Lathe.add(n, pedestal, Vector3(0, 0, -0.04), c, 0.85)
	var basin := _pv([[0.0, 0.7], [0.08, 0.7], [0.17, 0.73], [0.24, 0.79], [0.28, 0.86], [0.29, 0.9], [0.285, 0.915], [0.26, 0.915], [0.245, 0.88], [0.21, 0.83], [0.14, 0.79], [0.06, 0.775], [0.0, 0.775]])
	Lathe.add(n, basin, Vector3(0, 0, 0.0), c, 0.72)
	Props.cyl(n, Vector3(0, 0.777, 0.0), 0.022, 0.004, Materials.solid(Color(0.3, 0.3, 0.3), 0.3, 0.8), false)
	# Arka tabla + musluk.
	Props.box(n, Vector3(0, 0.9, -0.19), Vector3(0.5, 0.03, 0.08), c, false)
	Props.cyl(n, Vector3(0, 0.98, -0.19), 0.016, 0.14, chrome(), false)
	var spout := Props.cyl(n, Vector3(0, 1.045, -0.13), 0.013, 0.13, chrome(), false)
	spout.rotation_degrees.x = 90
	Props.sphere(n, Vector3(0, 1.045, -0.19), 0.02, chrome())
	for sx in [-1.0, 1.0]:
		Props.cyl(n, Vector3(sx * 0.13, 0.94, -0.19), 0.012, 0.05, chrome(), false)
		var h := Props.box(n, Vector3(sx * 0.13, 0.97, -0.19), Vector3(0.07, 0.012, 0.012), chrome(), false)
		h.rotation_degrees.y = 45
		var h2 := Props.box(n, Vector3(sx * 0.13, 0.97, -0.19), Vector3(0.07, 0.012, 0.012), chrome(), false)
		h2.rotation_degrees.y = -45
	# Akan su (yüz yıkarken görünür).
	var stream := Props.cyl(n, Vector3(0, 0.91, -0.07), 0.006, 0.26, Materials.solid(Color(0.8, 0.9, 1.0), 0.02), false)
	stream.name = "WaterStream"
	stream.visible = false
	Props.collider(n, Vector3(0, 0.46, -0.02), Vector3(0.58, 0.92, 0.42))
	return n

static func towel_bar(p: Node3D, pos: Vector3, rot: float, tint: Color) -> Node3D:
	var n := Props.group_node(p, pos, rot, "TowelBar")
	var bar := Props.cyl(n, Vector3(0, 0, 0.07), 0.01, 0.6, chrome(), false)
	bar.rotation_degrees.z = 90
	for sx in [-1.0, 1.0]:
		var arm := Props.cyl(n, Vector3(sx * 0.3, 0, 0.035), 0.008, 0.07, chrome(), false)
		arm.rotation_degrees.x = 90
	var cloth := Materials.surface("cotton_jersey", 0.3, tint)
	Props.box(n, Vector3(0, -0.28, 0.055), Vector3(0.45, 0.56, 0.012), cloth, false)
	Props.box(n, Vector3(0, -0.2, 0.09), Vector3(0.45, 0.4, 0.012), cloth, false)
	Props.cyl(n, Vector3(0, 0.0, 0.072), 0.02, 0.45, cloth, false).rotation_degrees.z = 90
	return n

static func paper_roll(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "PaperRoll")
	var arm := Props.cyl(n, Vector3(0, 0, 0.05), 0.006, 0.1, chrome(), false)
	arm.rotation_degrees.x = 90
	var roll := Props.cyl(n, Vector3(0, 0, 0.075), 0.055, 0.1, Materials.solid(Color(0.95, 0.95, 0.93), 0.9), false)
	roll.rotation_degrees.z = 90
	return n
