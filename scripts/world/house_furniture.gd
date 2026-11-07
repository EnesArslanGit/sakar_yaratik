class_name HouseFurniture
## Her odanın eşya yerleşimi. Koordinatlar HouseLayout ile aynı (metre).
## M() = gerçek model (önü +Z). rot: 0 = arkası kuzeye, 180 = güneye, 90 = batıya, -90 = doğuya.
## Hikâye eşyaları gruplarla bulunur: alarm_clock, sink, mirror, flashlight_pickup.

const K := preload("res://scripts/world/furniture_kit.gd")
const BK := preload("res://scripts/world/bathroom_kit.gd")

static func M(h: Node3D, id: String, x: float, y: float, z: float, rot: float = 0.0, s: float = 1.0, solid: bool = true) -> Node3D:
	return ModelLib.place(h, id, Vector3(x, y, z), rot, s, solid)

## Yaratığın devirebileceği küçük eşya.
static func B(h: Node3D, id: String, x: float, y: float, z: float, rot: float = 0.0) -> Node3D:
	var n := M(h, id, x, y, z, rot, 1.0, false)
	n.add_to_group("breakable")
	return n

static func build(h: Node3D) -> void:
	_salon(h)
	_mutfak(h)
	_koridor(h)
	_yatak(h)
	_banyo(h)

static func _salon(h: Node3D) -> void:
	K.rug(h, Vector3(2.0, 0, 2.1), 2.0, 2.8, Color(0.75, 0.35, 0.3))
	M(h, "sofa_03", 0.6, 0, 2.1, 90.0)
	M(h, "CoffeeTable_01", 1.9, 0, 2.1, 90.0)
	B(h, "ceramic_vase_02", 1.9, 0.52, 2.4)
	M(h, "ArmChair_01", 3.5, 0, 2.1, -90.0)
	M(h, "ClassicConsole_01", 1.4, 0, 0.42)
	B(h, "ceramic_vase_01", 1.0, 0.95, 0.4)
	M(h, "hanging_picture_frame_02", 1.4, 1.65, 0.125, 0.0, 1.0, false)
	M(h, "wooden_bookshelf_worn", 5.61, 0, 0.78, -90.0)
	M(h, "vintage_grandfather_clock_01", 5.5, 0, 3.69, 180.0)

static func _mutfak(h: Node3D) -> void:
	K.counter(h, Vector3(7.8, 0, 0.42), 0.0, 3.2)
	M(h, "electric_stove", 9.7, 0, 0.45)
	K.fridge(h, Vector3(10.6, 0, 0.47), 0.0)
	M(h, "vintage_cabinet_01", 11.62, 0, 2.0, -90.0)
	B(h, "jug_01", 6.8, 0.91, 0.4)
	B(h, "wooden_bowl_01", 7.6, 0.91, 0.35)
	M(h, "round_wooden_table_01", 8.3, 0, 2.5, 0.0, 0.75)
	M(h, "dining_chair_02", 7.55, 0, 2.5, 90.0)
	M(h, "dining_chair_02", 9.05, 0, 2.5, -90.0)
	M(h, "dining_chair_02", 8.3, 0, 3.25, 180.0)
	B(h, "wooden_bowl_01", 8.3, 0.76, 2.4)
	M(h, "wall_clock", 7.4, 1.9, 3.875, 180.0, 1.0, false)

static func _koridor(h: Node3D) -> void:
	K.rug(h, Vector3(6.0, 0, 5.0), 7.0, 0.9, Color(0.7, 0.35, 0.25))
	M(h, "side_table_tall_01", 11.65, 0, 5.0)
	B(h, "ceramic_vase_01", 11.65, 0.76, 5.0)
	M(h, "side_table_tall_01", 0.35, 0, 5.0)
	B(h, "ceramic_vase_02", 0.35, 0.76, 5.0)
	M(h, "hanging_picture_frame_01", 5.5, 1.5, 5.875, 180.0, 1.0, false)
	M(h, "hanging_picture_frame_02", 7.0, 1.6, 4.125, 0.0, 1.0, false)

static func _yatak(h: Node3D) -> void:
	K.rug(h, Vector3(4.3, 0, 7.1), 2.4, 1.2, Color(0.45, 0.5, 0.75))
	M(h, "GothicBed_01", 4.3, 0, 8.85, 180.0)
	M(h, "ClassicNightstand_01", 5.45, 0, 9.69, 180.0)
	M(h, "ClassicNightstand_01", 3.15, 0, 9.69, 180.0)
	B(h, "alarm_clock_01", 5.45, 0.7, 9.7, 200.0).add_to_group("alarm_clock")
	var fl := M(h, "vintage_flashlight", 3.15, 0.7, 9.65, 140.0, 1.0, false)
	fl.add_to_group("flashlight_pickup")
	M(h, "Ottoman_01", 4.3, 0, 7.35)
	M(h, "GothicCabinet_01", 0.56, 0, 8.0, 90.0).add_to_group("hide_spot")
	M(h, "Shelf_01", 0.1, 0, 9.4, 90.0)
	M(h, "GothicCommode_01", 6.61, 0, 7.3, -90.0)
	M(h, "standing_picture_frame_01", 6.65, 1.21, 6.95, -110.0, 1.0, false)
	M(h, "book_encyclopedia_set_01", 6.7, 1.21, 7.75, -90.0, 1.0, false)
	M(h, "hanging_picture_frame_01", 6.875, 1.75, 7.3, -90.0, 1.0, false)
	M(h, "potted_plant_02", 6.45, 0, 9.45, 30.0)

static func _banyo(h: Node3D) -> void:
	K.rug(h, Vector3(10.9, 0, 8.55), 1.2, 0.6, Color(0.4, 0.75, 0.75))
	K.bathtub(h, Vector3(10.95, 0, 9.45), 90.0)
	M(h, "rubber_duck_toy", 11.1, 0.53, 9.45, 70.0, 1.0, false)
	BK.toilet(h, Vector3(7.45, 0, 9.4), 90.0)
	BK.paper_roll(h, Vector3(7.11, 0.7, 8.85), 90.0)
	BK.sink(h, Vector3(11.68, 0, 7.4), -90.0).add_to_group("sink")
	var mirror := Mirror.new()
	mirror.position = Vector3(11.87, 1.55, 7.4)
	mirror.rotation_degrees.y = -90.0
	mirror.add_to_group("mirror")
	h.add_child(mirror)
	M(h, "painted_wooden_shelves", 7.1, 0, 7.0, 90.0)
	M(h, "bleach_bottle", 7.3, 1.13, 6.88, 80.0, 1.0, false)
	M(h, "multi_cleaner_bottle", 7.28, 1.13, 7.12, 0.0, 1.0, false)
	BK.towel_bar(h, Vector3(8.0, 1.3, 6.11), 0.0, Color(0.85, 0.75, 0.55))
	M(h, "wicker_basket_01", 8.1, 0, 6.5, 15.0)
	M(h, "potted_plant_02", 11.75, 0, 6.35, 0.0, 0.6)
