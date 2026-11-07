class_name Lathe
## Bir profil eğrisini (x = yarıçap, y = yükseklik) Y ekseni etrafında döndürerek pürüzsüz mesh üretir.
## Porselen gibi yuvarlak eşyalar için (klozet, lavabo). Profil dıştan başlayıp kenardan içe dönerse içi oyuk olur.

static func mesh(profile: PackedVector2Array, segments: int = 48) -> ArrayMesh:
	var n := profile.size()
	var normals2d: Array[Vector2] = []
	for j in n:
		var prev := profile[maxi(j - 1, 0)]
		var next := profile[mini(j + 1, n - 1)]
		var t := (next - prev).normalized()
		normals2d.append(Vector2(t.y, -t.x))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in segments:
		var a0 := TAU * i / segments
		var a1 := TAU * (i + 1) / segments
		for j in n - 1:
			var A := _v(profile[j], a0)
			var B := _v(profile[j], a1)
			var C := _v(profile[j + 1], a1)
			var D := _v(profile[j + 1], a0)
			var nA := _nv(normals2d[j], a0)
			var nB := _nv(normals2d[j], a1)
			var nC := _nv(normals2d[j + 1], a1)
			var nD := _nv(normals2d[j + 1], a0)
			var u0 := float(i) / segments
			var u1 := float(i + 1) / segments
			var v0 := float(j) / (n - 1)
			var v1 := float(j + 1) / (n - 1)
			_vert(st, A, nA, Vector2(u0, v0))
			_vert(st, B, nB, Vector2(u1, v0))
			_vert(st, C, nC, Vector2(u1, v1))
			_vert(st, A, nA, Vector2(u0, v0))
			_vert(st, C, nC, Vector2(u1, v1))
			_vert(st, D, nD, Vector2(u0, v1))
	return st.commit()

static func _v(p: Vector2, a: float) -> Vector3:
	return Vector3(cos(a) * p.x, p.y, sin(a) * p.x)

static func _nv(n2: Vector2, a: float) -> Vector3:
	return Vector3(cos(a) * n2.x, n2.y, sin(a) * n2.x).normalized()

static func _vert(st: SurfaceTool, p: Vector3, nrm: Vector3, uv: Vector2) -> void:
	st.set_normal(nrm)
	st.set_uv(uv)
	st.add_vertex(p)

## Profili döndürüp sahneye ekler. sz: Z ekseninde basıklık (oval şekil için).
static func add(parent: Node3D, profile: PackedVector2Array, pos: Vector3, m: Material, sz: float = 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh(profile)
	mi.material_override = m
	mi.position = pos
	mi.scale = Vector3(1, 1, sz)
	parent.add_child(mi)
	return mi
