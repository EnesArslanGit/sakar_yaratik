class_name Materials
## Gerçek (CC0, Poly Haven) dokulardan malzeme üretir. Dokular `assets/textures/<ad>/` altında:
## albedo.jpg, normal.jpg, rough.jpg. Dünya koordinatlı triplanar: her boyuttaki kutuda doğru tekrar eder.

static var _cache := {}

## tile_m: dokunun kaç metrede bir tekrar ettiği. tint: renk tonu (beyaz = orijinal).
static func surface(tex: String, tile_m: float = 1.5, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var key := "%s_%s_%s" % [tex, tile_m, tint.to_html()]
	if _cache.has(key):
		return _cache[key]
	var dir := "res://assets/textures/%s/" % tex
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(dir + "albedo.jpg")
	m.albedo_color = tint
	if ResourceLoader.exists(dir + "normal.jpg"):
		m.normal_enabled = true
		m.normal_texture = load(dir + "normal.jpg")
		m.normal_scale = 1.0
	if ResourceLoader.exists(dir + "rough.jpg"):
		m.roughness_texture = load(dir + "rough.jpg")
		m.roughness = 1.0
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE / tile_m
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_cache[key] = m
	return m

## Düz renkli ama gerçekçi parlaklıkta malzeme (seramik, metal, boyalı ahşap).
static func solid(c: Color, roughness: float = 0.6, metallic: float = 0.0) -> StandardMaterial3D:
	var key := "solid_%s_%s_%s" % [c.to_html(), roughness, metallic]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	m.metallic = metallic
	_cache[key] = m
	return m

## Oda malzemeleri: zemin, duvar.
const ROOM_SKIN := {
	"Salon": {"floor": ["diagonal_parquet", 2.0], "wall": ["decrepit_wallpaper", 2.0]},
	"Mutfak": {"floor": ["checkered_pavement_tiles", 1.6], "wall": ["painted_plaster_wall", 2.5]},
	"Koridor": {"floor": ["dark_wooden_planks", 2.0], "wall": ["decrepit_wallpaper", 2.0]},
	"Yatak": {"floor": ["wood_floor_worn", 2.0], "wall": ["beige_wall_001", 2.5]},
	"Banyo": {"floor": ["brown_floor_tiles", 1.2], "wall": ["painted_plaster_wall", 2.0]},
}

static func room_floor(room: String) -> StandardMaterial3D:
	var s: Array = ROOM_SKIN[room]["floor"]
	return surface(s[0], s[1])

static func room_wall(room: String) -> StandardMaterial3D:
	var s: Array = ROOM_SKIN[room]["wall"]
	return surface(s[0], s[1])
