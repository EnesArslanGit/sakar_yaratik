class_name WindowBuilder
## Pencereler: ahşap kasa, kayıt (haç), cam, denizlik, perdeler, dışarıda gece gökyüzü + içeri ay ışığı.
## Hikâyede set_all_dark() ile hepsi simsiyah olur.

const SKY := Color(0.10, 0.14, 0.26)

static func build(p: Node3D) -> void:
	for w in HouseLayout.WINDOWS:
		_window(p, w)

static func _window(p: Node3D, w: Dictionary) -> void:
	var a: float = w["a"]
	var b: float = w["b"]
	var y0: float = w["y0"]
	var y1: float = w["y1"]
	var outs: float = w["out"]
	var mid := (a + b) / 2.0
	var wid := b - a
	var hei := y1 - y0
	var n := Props.group_node(p, Vector3.ZERO, 0.0, "Window")
	# Yerel koordinat: x = duvar boyunca, z = içeri doğru (+), y yukarı.
	if w["axis"] == "z":
		n.position = Vector3(mid, 0, w["at"])
		n.rotation_degrees.y = 0.0 if outs < 0.0 else 180.0
	else:
		n.position = Vector3(w["at"], 0, mid)
		n.rotation_degrees.y = 90.0 if outs < 0.0 else -90.0
	var wood := Materials.solid(Color(0.85, 0.82, 0.74), 0.5)
	var t := HouseLayout.WALL_T
	# Kasa (duvar kalınlığını kaplar).
	Props.box(n, Vector3(0, y0 + 0.02, 0), Vector3(wid, 0.04, t + 0.02), wood, false)
	Props.box(n, Vector3(0, y1 - 0.02, 0), Vector3(wid, 0.04, t + 0.02), wood, false)
	for sx in [-1.0, 1.0]:
		Props.box(n, Vector3(sx * (wid / 2.0 - 0.02), (y0 + y1) / 2.0, 0), Vector3(0.04, hei, t + 0.02), wood, false)
	# Kayıtlar (haç).
	Props.box(n, Vector3(0, (y0 + y1) / 2.0, 0), Vector3(0.04, hei, 0.05), wood, false)
	Props.box(n, Vector3(0, y0 + hei * 0.62, 0), Vector3(wid, 0.04, 0.05), wood, false)
	# Denizlik.
	Props.box(n, Vector3(0, y0 - 0.02, t / 2.0 + 0.06), Vector3(wid + 0.12, 0.04, 0.14), wood, false)
	# Cam.
	var glass := StandardMaterial3D.new()
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(0.6, 0.7, 0.8, 0.18)
	glass.roughness = 0.05
	glass.metallic = 0.3
	Props.box(n, Vector3(0, (y0 + y1) / 2.0, 0), Vector3(wid - 0.06, hei - 0.06, 0.008), glass, false)
	# Dışarısı: gece gökyüzü paneli.
	var sky := Props.box(n, Vector3(0, (y0 + y1) / 2.0, -0.6), Vector3(wid + 1.0, hei + 1.0, 0.02), SKY, false, 1.0)
	sky.add_to_group("window_sky")
	Props.box(n, Vector3(-wid * 0.2, (y0 + y1) / 2.0 - hei * 0.25, -0.55), Vector3(0.05, hei * 0.8, 0.02), Color(0.01, 0.01, 0.02), false)
	Props.box(n, Vector3(wid * 0.1, y1 - 0.15, -0.55), Vector3(wid * 0.7, 0.03, 0.02), Color(0.01, 0.01, 0.02), false)
	var moon := SpotLight3D.new()
	moon.position = Vector3(0, y1 + 0.3, -0.4)
	moon.rotation_degrees = Vector3(-35, 180, 0)
	moon.light_color = Color(0.55, 0.65, 1.0)
	moon.light_energy = 1.6
	moon.spot_range = 6.0
	moon.spot_angle = 38.0
	moon.shadow_enabled = false
	moon.add_to_group("moonlight")
	n.add_child(moon)
	if w.get("curtains", true):
		_curtains(n, wid, y1, t)

static func _curtains(n: Node3D, wid: float, y1: float, t: float) -> void:
	var cloth := Materials.surface("crepe_satin", 0.6, Color(0.45, 0.12, 0.12))
	var rod := Props.cyl(n, Vector3(0, y1 + 0.18, t / 2.0 + 0.1), 0.012, wid + 0.7, Materials.solid(Color(0.3, 0.22, 0.12), 0.4, 0.6), false)
	rod.rotation_degrees.z = 90
	var h := y1 + 0.15
	for sx in [-1.0, 1.0]:
		var cx: float = sx * (wid / 2.0 + 0.12)
		for k in 5:
			var fold := Props.cyl(n, Vector3(cx + (k - 2) * 0.055, h / 2.0 + 0.02, t / 2.0 + 0.1 + (k % 2) * 0.02), 0.035, h - 0.02, cloth, false)
			fold.scale = Vector3(1, 1, 0.6)

static func set_all_dark(tree: SceneTree) -> void:
	for s in tree.get_nodes_in_group("window_sky"):
		(s as MeshInstance3D).material_override = Materials.solid(Color(0, 0, 0), 1.0)
	for l in tree.get_nodes_in_group("moonlight"):
		(l as Light3D).visible = false
