class_name ScareFace
## Aynada bir anlığına beliren yaratık yüzü. Sadece ayna kamerası görür (katman 2).
## Görünüm planla uyumlu: koyu mor-gri küçük yuvarlak kafa, iri parlayan sarı-yeşil gözler, sırıtan ağız.

static func create(parent: Node) -> Node3D:
	var n := Node3D.new()
	n.name = "ScareFace"
	parent.add_child(n)
	var skin := Materials.solid(Color(0.13, 0.09, 0.15), 0.75)
	var eye := Props.mat(Color(0.85, 1.0, 0.3), 5.0)
	var pupil := Materials.solid(Color(0.02, 0.02, 0.02), 0.2)
	var tooth := Materials.solid(Color(0.85, 0.82, 0.7), 0.4)
	var head := Props.sphere(n, Vector3.ZERO, 0.24, skin)
	head.scale = Vector3(1.0, 1.15, 0.95)
	# Uzun, sıska boyun/omuzlar.
	Props.box(n, Vector3(0, -0.42, -0.05), Vector3(0.14, 0.4, 0.14), skin, false)
	Props.box(n, Vector3(0, -0.66, -0.05), Vector3(0.7, 0.16, 0.24), skin, false)
	for sx in [-1.0, 1.0]:
		Props.sphere(n, Vector3(sx * 0.095, 0.05, 0.19), 0.075, eye)
		var pu := Props.sphere(n, Vector3(sx * 0.095, 0.05, 0.255), 0.022, pupil)
		pu.scale = Vector3(0.5, 1.6, 0.5)
		var brow := Props.box(n, Vector3(sx * 0.1, 0.14, 0.2), Vector3(0.12, 0.025, 0.04), skin, false)
		brow.rotation_degrees.z = sx * -20.0
	Props.box(n, Vector3(0, -0.11, 0.2), Vector3(0.26, 0.07, 0.04), Materials.solid(Color(0.03, 0.0, 0.02), 0.5), false)
	for i in 7:
		var x := -0.11 + i * 0.036
		Props.box(n, Vector3(x, -0.085, 0.215), Vector3(0.022, 0.03, 0.015), tooth, false)
		Props.box(n, Vector3(x + 0.018, -0.135, 0.215), Vector3(0.022, 0.03, 0.015), tooth, false)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 0.05, 0.4)
	light.light_color = Color(0.7, 1.0, 0.4)
	light.light_energy = 0.8
	light.omni_range = 1.2
	light.light_cull_mask = 1 << (Mirror.MIRROR_ONLY_LAYER - 1)
	n.add_child(light)
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).layers = 1 << (Mirror.MIRROR_ONLY_LAYER - 1)
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return n
