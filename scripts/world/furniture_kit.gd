class_name FurnitureKit
## Gerçek modeli olmayan eşyalar, kodla detaylı: mutfak tezgâhı, buzdolabı, ayaklı küvet, klozet, lavabo, halı.
## pos = zemindeki merkez, rot = Y derece. Eşyanın arkası yerel -Z, önü +Z.

static func ceramic() -> StandardMaterial3D:
	return Materials.solid(Color(0.9, 0.9, 0.88), 0.12)

static func chrome() -> StandardMaterial3D:
	return Materials.solid(Color(0.85, 0.85, 0.87), 0.2, 0.5)

static func torus(p: Node3D, center: Vector3, inner: float, outer: float, m: Material) -> MeshInstance3D:
	var tm := TorusMesh.new()
	tm.inner_radius = inner
	tm.outer_radius = outer
	tm.rings = 32
	tm.ring_segments = 12
	var mi := MeshInstance3D.new()
	mi.mesh = tm
	mi.material_override = m
	mi.position = center
	p.add_child(mi)
	return mi

static func counter(p: Node3D, pos: Vector3, rot: float, w: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Counter")
	var body := Materials.solid(Color(0.36, 0.33, 0.27), 0.7)
	var door := Materials.surface("wood_floor_worn", 1.0, Color(0.85, 0.8, 0.7))
	Props.box(n, Vector3(0, 0.05, -0.03), Vector3(w, 0.1, 0.54), Materials.solid(Color(0.08, 0.07, 0.06), 0.9), false)
	Props.box(n, Vector3(0, 0.48, 0), Vector3(w, 0.76, 0.6), body)
	Props.box(n, Vector3(0, 0.885, 0.01), Vector3(w + 0.03, 0.05, 0.64), Materials.solid(Color(0.78, 0.76, 0.72), 0.22), false)
	var count := maxi(int(w / 0.6), 1)
	var dw := w / count
	for i in count:
		var x := -w / 2 + dw * (i + 0.5)
		Props.box(n, Vector3(x, 0.62, 0.305), Vector3(dw - 0.03, 0.16, 0.02), door, false)
		Props.box(n, Vector3(x, 0.32, 0.305), Vector3(dw - 0.03, 0.4, 0.02), door, false)
		var h := Props.cyl(n, Vector3(x, 0.66, 0.33), 0.008, 0.14, chrome(), false)
		h.rotation_degrees.z = 90
	Props.box(n, Vector3(0, 1.07, -0.29), Vector3(w, 0.32, 0.02), Materials.surface("checkered_pavement_tiles", 0.5, Color(0.9, 0.95, 0.95)), false)
	return n

static func fridge(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Fridge")
	var paint := Materials.solid(Color(0.86, 0.84, 0.76), 0.3)
	Props.box(n, Vector3(0, 0.82, 0), Vector3(0.7, 1.5, 0.68), paint)
	var top := Props.cyl(n, Vector3(0, 1.57, 0), 0.34, 0.68, paint, false)
	top.rotation_degrees.x = 90
	top.scale = Vector3(1.03, 1, 0.28)
	Props.box(n, Vector3(0, 0.05, 0), Vector3(0.64, 0.1, 0.62), Materials.solid(Color(0.1, 0.1, 0.1), 0.8), false)
	Props.box(n, Vector3(0, 1.12, 0.345), Vector3(0.66, 0.01, 0.01), Materials.solid(Color(0.4, 0.4, 0.38), 0.5), false)
	Props.box(n, Vector3(0.27, 1.3, 0.37), Vector3(0.03, 0.22, 0.04), chrome(), false)
	Props.box(n, Vector3(0.27, 0.85, 0.37), Vector3(0.03, 0.18, 0.04), chrome(), false)
	return n

## Pençe ayaklı eski küvet (üstten bakınca uçları yuvarlak).
static func bathtub(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Bathtub")
	var c := ceramic()
	var y := 0.38
	# İçi gerçekten oyuk gövde: dış stadyum şekli eksi iç stadyum şekli (CSG).
	var shell := CSGCombiner3D.new()
	shell.position = Vector3(0, y, 0)
	shell.material_override = c
	n.add_child(shell)
	_stadium(shell, 0.39, 0.45, 0.4, 0.0, CSGShape3D.OPERATION_UNION)
	_stadium(shell, 0.33, 0.45, 0.4, 0.06, CSGShape3D.OPERATION_SUBTRACTION)
	for s in [-1.0, 1.0]:
		for fx in [-1.0, 1.0]:
			Props.sphere(n, Vector3(fx * 0.27, 0.09, s * 0.55), 0.07, Materials.solid(Color(0.7, 0.55, 0.3), 0.3, 1.0))
	var water := Materials.solid(Color(0.55, 0.62, 0.6, 1.0), 0.05)
	Props.box(n, Vector3(0, y + 0.08, 0), Vector3(0.66, 0.01, 0.9), water, false)
	for s in [-1.0, 1.0]:
		Props.cyl(n, Vector3(0, y + 0.08, s * 0.45), 0.33, 0.01, water, false)
	Props.cyl(n, Vector3(0, y + 0.35, -0.8), 0.018, 0.3, chrome(), false)
	var spout := Props.cyl(n, Vector3(0, y + 0.5, -0.72), 0.015, 0.16, chrome(), false)
	spout.rotation_degrees.x = 90
	Props.collider(n, Vector3(0, 0.3, 0), Vector3(0.78, 0.6, 1.68))
	return n

## Üstten bakınca uçları yarım daire olan şekil (kutu + 2 silindir), CSG içinde.
static func _stadium(parent: CSGCombiner3D, r: float, half_len: float, h: float, lift: float, op: int) -> void:
	var b := CSGBox3D.new()
	b.size = Vector3(r * 2.0, h, half_len * 2.0)
	b.position.y = lift
	b.operation = op
	parent.add_child(b)
	for s in [-1.0, 1.0]:
		var cy := CSGCylinder3D.new()
		cy.radius = r
		cy.height = h
		cy.sides = 32
		cy.position = Vector3(0, lift, s * half_len)
		cy.operation = op
		parent.add_child(cy)

## Halı: çarpışmasız, yaratık üstünde kayabilir (Aşama 3).
static func rug(p: Node3D, pos: Vector3, w: float, d: float, tint: Color) -> Node3D:
	var n := Props.group_node(p, pos, 0.0, "Rug")
	n.add_to_group("rug")
	n.set_meta("size", Vector2(w, d))
	Props.box(n, Vector3(0, 0.006, 0), Vector3(w, 0.012, d), Materials.surface("dirty_carpet", 1.0, tint), false)
	Props.box(n, Vector3(0, 0.007, 0), Vector3(w - 0.25, 0.012, d - 0.25), Materials.surface("dirty_carpet", 0.7, tint.lightened(0.25)), false)
	return n
