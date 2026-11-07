class_name ProportionMod
extends SkeletonModifier3D
## Animasyondan SONRA kemik oranlarını değiştirir: uzun sallanan kollar, kısa tıknaz bacaklar,
## küçük kafa, kambur sırt. Uzatılan kemiğin çocuklarında ölçek geri alınır (bükülmede çarpılma olmasın).

var arm := MonsterConfig.ARM_STRETCH
var leg := MonsterConfig.LEG_STRETCH
var head := MonsterConfig.HEAD_SCALE
var hunch := MonsterConfig.HUNCH_DEG
var extra_hunch := 0.0           # sakarlık animasyonları için ek eğilme
var _plan: Array = []            # [bone_id, self_scale, parent_scale, extra_rot_x_deg]

func _ready() -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	var A := Vector3(1, arm, 1)
	var L := Vector3(1, leg, 1)
	var one := Vector3.ONE
	for side in ["L", "R"]:
		_add(sk, "DEF-upper_arm." + side, A, one)
		_add(sk, "DEF-forearm." + side, A, A)
		_add(sk, "DEF-hand." + side, one, A)
		_add(sk, "DEF-thigh." + side, L, one)
		_add(sk, "DEF-shin." + side, L, L)
		_add(sk, "DEF-foot." + side, one, L)
	_add(sk, "DEF-head", Vector3.ONE * head, one)
	_add(sk, "DEF-spine.002", one, one, 1.0)
	_add(sk, "DEF-spine.003", one, one, 1.0)
	_add(sk, "DEF-neck", one, one, -1.2)

func _add(sk: Skeleton3D, bone: String, s: Vector3, ps: Vector3, rot_factor: float = 0.0) -> void:
	var id := sk.find_bone(bone)
	if id >= 0:
		_plan.append([id, s, ps, rot_factor])

func _process_modification_with_delta(_delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	for p in _plan:
		var id: int = p[0]
		var s: Vector3 = p[1]
		var ps: Vector3 = p[2]
		var rf: float = p[3]
		var t := sk.get_bone_pose(id)
		var b := Basis.from_scale(Vector3.ONE / ps) * t.basis
		if rf != 0.0:
			b = b * Basis(Vector3.RIGHT, deg_to_rad((hunch + extra_hunch) * rf))
		b = b * Basis.from_scale(s)
		sk.set_bone_pose(id, Transform3D(b, t.origin))
