class_name MonsterBody
extends Node3D
## Yaratığın görünümü ve animasyonları.
## Model: Quaternius "Universal Animation Library" mankeni (CC0) → oranları değiştirilir (ProportionMod),
## koyu mor-gri ıslak deri, iri parlayan sarı-yeşil gözler, sırıtan ağız.
## Önü yerel -Z (look_at ile uyumlu).

const SCENE := "res://assets/characters/ual/ual.glb"
const EYE_COLOR := Color(0.8, 1.0, 0.25)

## Kafa kemiğine göre yüz yerleşimi (deneme ile ayarlandı).
const FACE_FWD := Vector3(0, 0, 1)
const EYE_UP := 0.115
const EYE_SIDE := 0.05
const EYE_FWD := 0.085

var anim: AnimationPlayer
var skeleton: Skeleton3D
var mod: ProportionMod
var layer_mask := 1
var _current := ""
var _eye_light: OmniLight3D

func _ready() -> void:
	var inst: Node3D = (load(SCENE) as PackedScene).instantiate()
	inst.rotation_degrees.y = 180.0
	inst.scale = Vector3.ONE * MonsterConfig.BODY_SCALE
	add_child(inst)
	skeleton = inst.find_child("Skeleton3D", true, false)
	anim = inst.find_child("AnimationPlayer", true, false)
	for loop_name in ["Walk", "Jog_Fwd", "Sprint", "Idle", "Crouch_Fwd", "Crouch_Idle", "Push", "Swim_Idle"]:
		if anim.has_animation(loop_name):
			anim.get_animation(loop_name).loop_mode = Animation.LOOP_LINEAR
	mod = ProportionMod.new()
	skeleton.add_child(mod)
	_skin()
	_face()
	for mi in find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).layers = layer_mask
	play("Idle")

func _skin() -> void:
	var mi: MeshInstance3D = skeleton.find_child("Mannequin", true, false)
	var dir := "res://assets/textures/brown_leather/"
	var skin := StandardMaterial3D.new()
	skin.albedo_texture = load(dir + "albedo.jpg")
	skin.albedo_color = Color(0.2, 0.15, 0.26)
	skin.normal_enabled = true
	skin.normal_texture = load(dir + "normal.jpg")
	skin.normal_scale = 0.9
	skin.roughness_texture = load(dir + "rough.jpg")
	skin.roughness = 0.7
	skin.uv1_triplanar = true
	skin.uv1_scale = Vector3.ONE * 4.0
	skin.rim_enabled = true
	skin.rim = 0.35
	skin.rim_tint = 0.6
	var joints := skin.duplicate() as StandardMaterial3D
	joints.albedo_color = Color(0.14, 0.09, 0.16)
	mi.set_surface_override_material(0, skin)
	if mi.mesh.get_surface_count() > 1:
		mi.set_surface_override_material(1, joints)

func _face() -> void:
	var ba := BoneAttachment3D.new()
	ba.bone_name = "DEF-head"
	skeleton.add_child(ba)
	var face := Node3D.new()
	ba.add_child(face)
	face.basis = Basis.looking_at(FACE_FWD, Vector3.UP)
	var eye := Props.mat(EYE_COLOR, 5.0)
	var pupil := Materials.solid(Color(0.02, 0.02, 0.0), 0.2)
	var tooth := Materials.solid(Color(0.86, 0.83, 0.7), 0.35)
	var dark := Materials.solid(Color(0.04, 0.0, 0.03), 0.5)
	for sx in [-1.0, 1.0]:
		var e := Props.sphere(face, Vector3(sx * EYE_SIDE, EYE_UP, -EYE_FWD), 0.042, eye)
		e.scale = Vector3(1.0, 1.15, 0.7)
		var pu := Props.sphere(face, Vector3(sx * EYE_SIDE, EYE_UP, -EYE_FWD - 0.022), 0.01, pupil)
		pu.scale = Vector3(0.45, 1.8, 0.5)
	Props.box(face, Vector3(0, EYE_UP - 0.07, -EYE_FWD + 0.005), Vector3(0.1, 0.022, 0.02), dark, false)
	for i in 6:
		var x := -0.042 + i * 0.017
		Props.box(face, Vector3(x, EYE_UP - 0.062, -EYE_FWD - 0.006), Vector3(0.01, 0.012, 0.006), tooth, false)
		Props.box(face, Vector3(x + 0.008, EYE_UP - 0.078, -EYE_FWD - 0.006), Vector3(0.01, 0.012, 0.006), tooth, false)
	_eye_light = OmniLight3D.new()
	_eye_light.position = Vector3(0, EYE_UP, -EYE_FWD - 0.15)
	_eye_light.light_color = EYE_COLOR
	_eye_light.light_energy = 0.35
	_eye_light.omni_range = 1.4
	_eye_light.shadow_enabled = false
	_eye_light.light_cull_mask = layer_mask if layer_mask != 1 else 0xFFFFF
	face.add_child(_eye_light)

## Animasyon oynatır (aynıysa tekrar başlatmaz). speed: oynatma hızı.
func play(anim_name: String, speed: float = 1.0, blend: float = 0.25, restart: bool = false) -> void:
	if not anim.has_animation(anim_name):
		push_warning("Animasyon yok: " + anim_name)
		return
	if anim_name == _current and not restart:
		anim.speed_scale = speed
		return
	_current = anim_name
	anim.play(anim_name, blend, 1.0)
	anim.speed_scale = speed

## Animasyonu geriye oynat (ör. düştükten sonra kalkma).
func play_backwards(anim_name: String, speed: float = 1.0) -> void:
	_current = anim_name + "_back"
	anim.speed_scale = speed
	anim.play_backwards(anim_name, 0.15)

func anim_length(anim_name: String) -> float:
	return anim.get_animation(anim_name).length if anim.has_animation(anim_name) else 1.0

func current() -> String:
	return _current
