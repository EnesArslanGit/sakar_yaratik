class_name Props
## Basit şekil üreticileri (kutu, silindir, küre) + çarpışma. Tüm eşyalar bunları kullanır.

static var _mats := {}

static func mat(c: Color, glow: float = 0.0) -> StandardMaterial3D:
	var key := "%s_%s" % [c.to_html(), glow]
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.85
	if glow > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = glow
	_mats[key] = m
	return m

static func group_node(parent: Node3D, pos: Vector3, rot_deg: float = 0.0, node_name: String = "") -> Node3D:
	var n := Node3D.new()
	if node_name != "":
		n.name = node_name
	n.position = pos
	n.rotation_degrees.y = rot_deg
	parent.add_child(n)
	return n

static func box(parent: Node3D, center: Vector3, size: Vector3, c: Color, solid: bool = true, glow: float = 0.0) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	var mi := _mesh(parent, bm, center, c, glow)
	if solid:
		var s := BoxShape3D.new()
		s.size = size
		_body(mi, s)
	return mi

static func cyl(parent: Node3D, center: Vector3, radius: float, height: float, c: Color, solid: bool = true, top_radius: float = -1.0) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.bottom_radius = radius
	cm.top_radius = radius if top_radius < 0.0 else top_radius
	cm.height = height
	cm.radial_segments = 12
	cm.rings = 1
	var mi := _mesh(parent, cm, center, c, 0.0)
	if solid:
		var s := CylinderShape3D.new()
		s.radius = radius
		s.height = height
		_body(mi, s)
	return mi

static func sphere(parent: Node3D, center: Vector3, radius: float, c: Color, glow: float = 0.0) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 12
	sm.rings = 6
	return _mesh(parent, sm, center, c, glow)

## Görünmez çarpışma kutusu (görseli ince olan eşyalar için tek, dolu engel).
static func collider(parent: Node3D, center: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	var cs := CollisionShape3D.new()
	var s := BoxShape3D.new()
	s.size = size
	cs.shape = s
	body.add_child(cs)
	parent.add_child(body)
	return body

static func _mesh(parent: Node3D, mesh: Mesh, center: Vector3, c: Color, glow: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(c, glow)
	mi.position = center
	if glow > 0.0:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func _body(mi: MeshInstance3D, shape: Shape3D) -> void:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	mi.add_child(body)
