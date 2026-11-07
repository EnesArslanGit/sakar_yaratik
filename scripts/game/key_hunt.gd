class_name KeyHunt
extends Node
## 3 anahtar parçası: her oyunda farklı odalarda rastgele yerlere konur. Hepsi toplanınca çıkış kapısı açılır.
## Parçalar küçük pirinç anahtar parçalarıdır; fener ışığında parlar.

signal all_found
signal part_found(count: int)

## Oda başına aday yerler (x, y, z) — eşya üstleri ve zemin köşeleri.
const SPOTS := {
	"Salon": [Vector3(1.75, 0.53, 1.8), Vector3(1.9, 0.96, 0.4), Vector3(3.9, 0.02, 2.75), Vector3(4.9, 0.02, 3.55)],
	"Mutfak": [Vector3(8.7, 0.92, 0.45), Vector3(8.55, 0.77, 2.75), Vector3(10.6, 0.02, 1.15), Vector3(11.2, 0.02, 3.6)],
	"Koridor": [Vector3(11.65, 0.77, 5.2), Vector3(0.7, 0.02, 5.6), Vector3(7.8, 0.02, 4.4)],
	"Yatak": [Vector3(6.62, 1.22, 7.55), Vector3(4.3, 0.63, 7.35), Vector3(2.4, 0.02, 9.4), Vector3(1.5, 0.02, 6.6)],
	"Banyo": [Vector3(10.0, 0.02, 9.0), Vector3(7.6, 0.02, 6.4), Vector3(11.4, 0.02, 8.3)],
}
const NAMES := ["anahtarın halkası", "anahtarın gövdesi", "anahtarın dişleri"]

var found := 0
var _parts: Array[Node3D] = []

func spawn() -> void:
	var rooms := SPOTS.keys()
	rooms.shuffle()
	for i in 3:
		var options: Array = SPOTS[rooms[i]]
		var pos: Vector3 = options[randi() % options.size()]
		_parts.append(_make_part(i, pos))

func _make_part(i: int, pos: Vector3) -> Node3D:
	var n := Props.group_node(get_tree().current_scene, pos, randf_range(0, 360), "KeyPart%d" % i)
	var brass := Materials.solid(Color(0.85, 0.65, 0.3), 0.25, 1.0)
	match i:
		0:
			var ring := FurnitureKit.torus(n, Vector3(0, 0.01, 0), 0.025, 0.045, brass)
			ring.scale = Vector3(1, 0.5, 1)
		1:
			var shaft := Props.cyl(n, Vector3(0, 0.008, 0), 0.007, 0.11, brass, false)
			shaft.rotation_degrees.z = 90
		2:
			Props.box(n, Vector3(0, 0.008, 0), Vector3(0.05, 0.012, 0.028), brass, false)
			for k in 3:
				Props.box(n, Vector3(-0.015 + k * 0.015, 0.008, 0.02), Vector3(0.008, 0.012, 0.014 + k * 0.006), brass, false)
	# Fener ışığında fark edilsin diye küçük parıltı.
	var glint := Props.sphere(n, Vector3(0, 0.03, 0), 0.006, Color(1.0, 0.85, 0.5), 6.0)
	glint.name = "Glint"
	var it := Interactable.attach(n, "Al: %s" % NAMES[i], Vector3(0, 0.05, 0))
	it.used.connect(func(_p): _take(n))
	return n

func _take(n: Node3D) -> void:
	found += 1
	Sfx.play(self, "pickup", null, 0.0, 1.8)
	n.queue_free()
	part_found.emit(found)
	if found >= 3:
		all_found.emit()

func _process(_d: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for p in _parts:
		if is_instance_valid(p):
			var g := p.get_node_or_null("Glint")
			if g:
				g.visible = fmod(t + p.position.x, 2.2) < 0.25
