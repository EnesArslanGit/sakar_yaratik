class_name ModelLib
## Gerçek 3D modelleri (CC0, Poly Haven, `assets/models/<id>/<id>_1k.gltf`) yerleştirir.
## Modellerin önü +Z, tabanı y=0. Çarpışma: modelin sınır kutusundan otomatik tek kutu.

static var _scenes := {}

## pos: zemindeki nokta, rot: Y derece, s: ölçek. solid=false ise çarpışma eklenmez.
static func place(parent: Node3D, id: String, pos: Vector3, rot: float = 0.0, s: float = 1.0, solid: bool = true) -> Node3D:
	if not _scenes.has(id):
		_scenes[id] = load("res://assets/models/%s/%s_1k.gltf" % [id, id])
	var ps: PackedScene = _scenes[id]
	var root := Props.group_node(parent, pos, rot, id)
	var inst: Node3D = ps.instantiate()
	inst.scale = Vector3.ONE * s
	root.add_child(inst)
	if solid:
		var box := local_aabb(inst)
		Props.collider(root, box.get_center(), box.size)
	return root

## Modelin (kök düğüme göre) sınır kutusu.
static func local_aabb(inst: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for node in inst.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var t := Transform3D.IDENTITY
		var cur: Node = mi
		while cur != inst.get_parent() and cur is Node3D:
			t = (cur as Node3D).transform * t
			cur = cur.get_parent()
		var b := t * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box
