class_name Mirror
extends Node3D
## Gerçek düzlem ayna: ayrı bir kamera yansımayı çizer, sonuç camın üstüne yansıtılır.
## Sadece oyuncu yakındayken çalışır (performans). Görsel katman 2 = sadece aynada görünenler
## (oyuncunun yansıyan bedeni, korkunç yüz). Önü yerel +Z.

const MIRROR_ONLY_LAYER := 2   # görsel katman numarası (1'den başlar)
const ACTIVE_DIST := 5.0

var size := Vector2(0.52, 0.72)
var _vp: SubViewport
var _cam: Camera3D
var _glass: MeshInstance3D
var _dark := false

func _ready() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(384, int(384 * size.y / size.x))
	_vp.msaa_3d = Viewport.MSAA_2X
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_vp)
	_cam = Camera3D.new()
	_cam.projection = Camera3D.PROJECTION_FRUSTUM
	_cam.keep_aspect = Camera3D.KEEP_HEIGHT
	_vp.add_child(_cam)
	var frame := Materials.solid(Color(0.25, 0.18, 0.1), 0.4, 0.3)
	Props.box(self, Vector3(0, 0, -0.012), Vector3(size.x + 0.1, size.y + 0.1, 0.025), frame, false)
	_glass = MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	_glass.mesh = q
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_texture = _vp.get_texture()
	m.uv1_scale = Vector3(-1, 1, 1)
	m.uv1_offset = Vector3(1, 0, 0)
	_glass.material_override = m
	_glass.position.z = 0.002
	add_child(_glass)

## Lambalar patlayınca ayna da kararır.
func set_dark(v: bool) -> void:
	_dark = v
	var m := _glass.material_override as StandardMaterial3D
	m.albedo_color = Color(0.05, 0.05, 0.06) if v else Color.WHITE

func _process(_d: float) -> void:
	var main := get_viewport().get_camera_3d()
	if main == null:
		return
	var near := main.global_position.distance_to(global_position) < ACTIVE_DIST
	var facing := (main.global_position - global_position).dot(global_basis.z) > 0.0
	var on := near and facing and not _dark
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	if on:
		_update_camera(main)

func _update_camera(main: Camera3D) -> void:
	var n := global_basis.z.normalized()
	var right := global_basis.x.normalized()
	var up := global_basis.y.normalized()
	var p := global_position
	var c := main.global_position
	var refl := c - 2.0 * (c - p).dot(n) * n
	_cam.global_transform = Transform3D(Basis(-right, up, -n), refl)
	var rel := p - refl
	var dist := rel.dot(n)
	_cam.set_frustum(size.y, Vector2(rel.dot(-right), rel.dot(up)), maxf(dist, 0.05), 40.0)
	_cam.cull_mask = 0xFFFFF
