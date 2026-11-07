class_name ExitDoor
## Salondaki kilitli çıkış kapısı: panelli ahşap kanat, pirinç kol, yeşil ÇIKIŞ tabelası.

static func build(p: Node3D) -> Node3D:
	var n := Props.group_node(p, HouseLayout.EXIT_DOOR, 0.0, "ExitDoor")
	n.add_to_group("exit_door")
	var wood := Materials.surface("dark_wooden_planks", 1.2, Color(0.75, 0.55, 0.42))
	var panel := Materials.surface("dark_wooden_planks", 1.2, Color(0.6, 0.42, 0.3))
	var brass := Materials.solid(Color(0.78, 0.6, 0.3), 0.3, 1.0)
	var dh := HouseLayout.DOOR_H
	Props.box(n, Vector3(0, dh / 2.0, 0), Vector3(1.0, dh, 0.05), wood)
	for side in [-1.0, 1.0]:
		var z: float = side * 0.03
		for row in [[0.25, 0.85], [1.1, 1.9]]:
			for col in [-0.21, 0.21]:
				var y: float = (row[0] + row[1]) / 2.0
				Props.box(n, Vector3(col, y, z), Vector3(0.32, row[1] - row[0], 0.015), panel, false)
		Props.cyl(n, Vector3(0.38, 1.0, side * 0.045), 0.035, 0.02, brass, false)
		var knob := Props.sphere(n, Vector3(0.38, 1.0, side * 0.075), 0.032, brass)
		knob.scale = Vector3(1, 1, 0.8)
		Props.box(n, Vector3(0.38, 0.88, side * 0.03), Vector3(0.04, 0.09, 0.012), brass, false)
	# Yeşil "ÇIKIŞ" tabelası: karanlıkta yön bulmaya yardım eder.
	Props.box(n, Vector3(0, 2.3, 0.12), Vector3(0.45, 0.16, 0.03), Color(0.1, 0.9, 0.35), false, 2.5)
	return n
