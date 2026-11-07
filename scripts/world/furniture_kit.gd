class_name FurnitureKit
## Birleşik eşyalar (masa, sandalye, kanepe, yatak, dolap, tezgâh, küvet...).
## pos = zemindeki merkez, rot = Y ekseninde derece. Eşyanın arkası yerel -Z yönündedir.

const WOOD := Color(0.36, 0.23, 0.13)
const DARK_WOOD := Color(0.20, 0.12, 0.07)
const CERAMIC := Color(0.86, 0.87, 0.88)
const METAL := Color(0.45, 0.46, 0.48)

static func table(p: Node3D, pos: Vector3, w: float, d: float, h: float, c: Color = WOOD, rot: float = 0.0) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Table")
	Props.box(n, Vector3(0, h - 0.03, 0), Vector3(w, 0.06, d), c, false)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Props.box(n, Vector3(sx * (w / 2 - 0.06), (h - 0.06) / 2, sz * (d / 2 - 0.06)), Vector3(0.06, h - 0.06, 0.06), c.darkened(0.25), false)
	Props.collider(n, Vector3(0, h / 2, 0), Vector3(w, h, d))
	return n

static func chair(p: Node3D, pos: Vector3, rot: float, c: Color = WOOD) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Chair")
	Props.box(n, Vector3(0, 0.45, 0), Vector3(0.45, 0.05, 0.45), c, false)
	Props.box(n, Vector3(0, 0.75, -0.2), Vector3(0.45, 0.55, 0.05), c, false)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Props.box(n, Vector3(sx * 0.19, 0.22, sz * 0.19), Vector3(0.05, 0.44, 0.05), c.darkened(0.25), false)
	Props.collider(n, Vector3(0, 0.5, 0), Vector3(0.45, 1.0, 0.45))
	return n

static func sofa(p: Node3D, pos: Vector3, rot: float, w: float, c: Color) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Sofa")
	Props.box(n, Vector3(0, 0.22, 0), Vector3(w, 0.44, 0.9), c)
	Props.box(n, Vector3(0, 0.48, 0.05), Vector3(w - 0.4, 0.1, 0.75), c.lightened(0.12), false)
	Props.box(n, Vector3(0, 0.7, -0.35), Vector3(w, 0.55, 0.2), c)
	for sx in [-1.0, 1.0]:
		Props.box(n, Vector3(sx * (w / 2 - 0.1), 0.57, 0), Vector3(0.2, 0.26, 0.9), c.darkened(0.1))
	return n

static func bed(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Bed")
	Props.box(n, Vector3(0, 0.17, 0), Vector3(1.6, 0.34, 2.1), DARK_WOOD)
	Props.box(n, Vector3(0, 0.44, 0.02), Vector3(1.5, 0.2, 2.0), Color(0.78, 0.76, 0.70), false)
	Props.box(n, Vector3(0, 0.56, 0.35), Vector3(1.52, 0.06, 1.3), Color(0.35, 0.18, 0.30), false)
	Props.box(n, Vector3(0, 0.6, -0.75), Vector3(1.1, 0.12, 0.35), Color(0.9, 0.9, 0.86), false)
	Props.box(n, Vector3(0, 0.55, -1.03), Vector3(1.6, 1.1, 0.08), DARK_WOOD)
	return n

## Saklanılabilen dolap (Aşama 4'te içine girilecek).
static func wardrobe(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Wardrobe")
	n.add_to_group("hide_spot")
	Props.box(n, Vector3(0, 1.05, 0), Vector3(1.2, 2.1, 0.6), DARK_WOOD)
	Props.box(n, Vector3(0, 1.05, 0.305), Vector3(0.02, 1.9, 0.01), Color(0.05, 0.03, 0.02), false)
	for sx in [-1.0, 1.0]:
		Props.sphere(n, Vector3(sx * 0.08, 1.05, 0.32), 0.025, Color(0.7, 0.55, 0.25))
	return n

static func counter(p: Node3D, pos: Vector3, rot: float, w: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Counter")
	Props.box(n, Vector3(0, 0.44, 0), Vector3(w, 0.88, 0.6), Color(0.55, 0.50, 0.42))
	Props.box(n, Vector3(0, 0.9, 0.01), Vector3(w + 0.02, 0.04, 0.62), Color(0.75, 0.73, 0.70), false)
	var doors := int(w / 0.6)
	for i in doors:
		var x := -w / 2 + 0.3 + i * (w / doors)
		Props.box(n, Vector3(x, 0.45, 0.305), Vector3(0.5, 0.7, 0.01), Color(0.48, 0.43, 0.36), false)
	return n

static func stove(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Stove")
	Props.box(n, Vector3(0, 0.45, 0), Vector3(0.6, 0.9, 0.6), Color(0.15, 0.15, 0.16))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Props.cyl(n, Vector3(sx * 0.14, 0.91, sz * 0.14), 0.09, 0.02, Color(0.05, 0.05, 0.05), false)
	return n

static func fridge(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Fridge")
	Props.box(n, Vector3(0, 0.9, 0), Vector3(0.7, 1.8, 0.7), Color(0.78, 0.80, 0.76))
	Props.box(n, Vector3(0.28, 1.1, 0.36), Vector3(0.03, 0.5, 0.03), METAL, false)
	return n

static func bathtub(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Bathtub")
	Props.box(n, Vector3(0, 0.28, 0), Vector3(0.8, 0.56, 1.7), CERAMIC)
	Props.box(n, Vector3(0, 0.565, 0), Vector3(0.64, 0.02, 1.54), Color(0.25, 0.32, 0.36), false)
	Props.cyl(n, Vector3(0, 0.75, -0.8), 0.025, 0.4, METAL, false)
	return n

static func sink(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Sink")
	Props.cyl(n, Vector3(0, 0.4, -0.05), 0.09, 0.8, CERAMIC)
	Props.box(n, Vector3(0, 0.85, 0), Vector3(0.55, 0.14, 0.42), CERAMIC)
	Props.box(n, Vector3(0, 1.45, -0.2), Vector3(0.5, 0.65, 0.02), Color(0.55, 0.62, 0.66), false)
	return n

static func toilet(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Toilet")
	Props.cyl(n, Vector3(0, 0.2, 0.05), 0.2, 0.4, CERAMIC)
	Props.box(n, Vector3(0, 0.6, -0.2), Vector3(0.4, 0.4, 0.18), CERAMIC)
	return n

static func bookshelf(p: Node3D, pos: Vector3, rot: float) -> Node3D:
	var n := Props.group_node(p, pos, rot, "Bookshelf")
	Props.box(n, Vector3(0, 0.9, 0), Vector3(1.0, 1.8, 0.35), WOOD)
	var colors := [Color(0.5, 0.15, 0.1), Color(0.15, 0.3, 0.45), Color(0.4, 0.38, 0.2), Color(0.2, 0.35, 0.2)]
	for shelf in 4:
		for b in 6:
			var h := 0.22 + (b % 3) * 0.03
			Props.box(n, Vector3(-0.38 + b * 0.15, 0.2 + shelf * 0.42 + h / 2, 0.18), Vector3(0.11, h, 0.02), colors[(b + shelf) % 4], false)
	return n

## Kırılabilir küçük eşyalar: yaratık devirebilir (Aşama 3).
static func vase(p: Node3D, pos: Vector3, c: Color = Color(0.25, 0.4, 0.55)) -> Node3D:
	var n := Props.group_node(p, pos, 0.0, "Vase")
	n.add_to_group("breakable")
	Props.cyl(n, Vector3(0, 0.12, 0), 0.07, 0.24, c, false, 0.05)
	Props.cyl(n, Vector3(0, 0.27, 0), 0.04, 0.06, c.darkened(0.2), false)
	return n

static func plate(p: Node3D, pos: Vector3) -> Node3D:
	var n := Props.group_node(p, pos, 0.0, "Plate")
	n.add_to_group("breakable")
	Props.cyl(n, Vector3(0, 0.01, 0), 0.12, 0.02, Color(0.9, 0.88, 0.82), false)
	return n

## Halı: çarpışmasız, yaratık üstünde kayabilir (Aşama 3).
static func rug(p: Node3D, pos: Vector3, w: float, d: float, c: Color) -> Node3D:
	var n := Props.group_node(p, pos, 0.0, "Rug")
	n.add_to_group("rug")
	n.set_meta("size", Vector2(w, d))
	Props.box(n, Vector3(0, 0.006, 0), Vector3(w, 0.012, d), c, false)
	Props.box(n, Vector3(0, 0.007, 0), Vector3(w - 0.3, 0.012, d - 0.3), c.lightened(0.15), false)
	return n
