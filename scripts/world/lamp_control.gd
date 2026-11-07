class_name LampControl
## Tavan lambalarını ("lamp" grubu) titretir ve patlatır (hikâyedeki elektrik kesintisi).

static func _parts(lamp: Node) -> Array:
	var light: Light3D = null
	var bulb: MeshInstance3D = null
	for c in lamp.get_children():
		if c is Light3D:
			light = c
		elif c is MeshInstance3D and (c as MeshInstance3D).mesh is SphereMesh:
			bulb = c
	return [light, bulb]

static func set_on(lamp: Node, on: bool) -> void:
	var p := _parts(lamp)
	if p[0]:
		(p[0] as Light3D).visible = on
	if p[1]:
		(p[1] as MeshInstance3D).material_override = Props.mat(Color(1.0, 0.85, 0.6), 4.0) if on else Materials.solid(Color(0.15, 0.14, 0.12), 0.3)

## seconds boyunca rastgele yanıp söner (cızırtı sesiyle).
static func flicker_all(node: Node, seconds: float) -> void:
	var tree := node.get_tree()
	var lamps := tree.get_nodes_in_group("lamp")
	var buzz := Sfx.play(node, "buzz", null, -8.0)
	var t := 0.0
	while t < seconds:
		for l in lamps:
			set_on(l, randf() > 0.45)
		var step := randf_range(0.04, 0.16)
		await tree.create_timer(step).timeout
		t += step
	for l in lamps:
		set_on(l, true)
	buzz.queue_free()

## Lambalar birer birer patlar.
static func burst_all(node: Node, gap: float = 0.22) -> void:
	var tree := node.get_tree()
	for l in tree.get_nodes_in_group("lamp"):
		set_on(l, false)
		Sfx.play(node, "pop", (l as Node3D).global_position + Vector3(0, -0.6, 0))
		await tree.create_timer(gap).timeout
