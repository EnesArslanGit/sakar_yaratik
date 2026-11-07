class_name HouseFurniture
## Her odanın eşya yerleşimi. Koordinatlar HouseLayout ile aynı (metre).


static func build(h: Node3D) -> void:
	_salon(h)
	_mutfak(h)
	_koridor(h)
	_yatak(h)
	_banyo(h)

static func _salon(h: Node3D) -> void:
	FurnitureKit.rug(h, Vector3(2.0, 0, 2.1), 2.2, 2.6, Color(0.35, 0.10, 0.10))
	FurnitureKit.sofa(h, Vector3(0.55, 0, 2.1), 90.0, 2.0, Color(0.22, 0.30, 0.22))
	FurnitureKit.table(h, Vector3(2.1, 0, 2.1), 0.6, 1.0, 0.42)
	FurnitureKit.vase(h, Vector3(2.1, 0.42, 2.3), Color(0.55, 0.3, 0.15))
	FurnitureKit.table(h, Vector3(1.2, 0, 0.35), 1.4, 0.4, 0.8, FurnitureKit.DARK_WOOD)
	FurnitureKit.vase(h, Vector3(0.8, 0.8, 0.35))
	FurnitureKit.bookshelf(h, Vector3(5.72, 0, 3.2), -90.0)
	FurnitureKit.sofa(h, Vector3(3.4, 0, 3.4), 180.0, 1.0, Color(0.40, 0.22, 0.12))

static func _mutfak(h: Node3D) -> void:
	FurnitureKit.counter(h, Vector3(8.2, 0, 0.4), 0.0, 3.6)
	FurnitureKit.stove(h, Vector3(10.4, 0, 0.4), 0.0)
	FurnitureKit.fridge(h, Vector3(11.5, 0, 0.5), 0.0)
	FurnitureKit.plate(h, Vector3(7.2, 0.92, 0.4))
	FurnitureKit.plate(h, Vector3(7.5, 0.92, 0.45))
	FurnitureKit.vase(h, Vector3(9.4, 0.92, 0.35), Color(0.6, 0.55, 0.3))
	FurnitureKit.rug(h, Vector3(8.2, 0, 1.15), 2.0, 0.6, Color(0.30, 0.25, 0.15))
	FurnitureKit.table(h, Vector3(9.0, 0, 2.5), 1.2, 0.8, 0.75)
	FurnitureKit.chair(h, Vector3(8.15, 0, 2.5), 90.0)
	FurnitureKit.chair(h, Vector3(9.85, 0, 2.5), -90.0)
	FurnitureKit.chair(h, Vector3(9.0, 0, 3.25), 180.0)
	FurnitureKit.plate(h, Vector3(8.8, 0.75, 2.5))
	FurnitureKit.plate(h, Vector3(9.2, 0.75, 2.4))

static func _koridor(h: Node3D) -> void:
	FurnitureKit.rug(h, Vector3(6.0, 0, 5.0), 7.0, 0.9, Color(0.32, 0.16, 0.10))
	FurnitureKit.table(h, Vector3(11.65, 0, 5.0), 0.4, 0.8, 0.8, FurnitureKit.DARK_WOOD)
	FurnitureKit.vase(h, Vector3(11.65, 0.8, 5.0), Color(0.5, 0.2, 0.35))
	FurnitureKit.table(h, Vector3(0.35, 0, 5.0), 0.4, 0.7, 0.8, FurnitureKit.DARK_WOOD)
	FurnitureKit.vase(h, Vector3(0.35, 0.8, 4.9))

static func _yatak(h: Node3D) -> void:
	FurnitureKit.bed(h, Vector3(4.3, 0, 8.9), 180.0)
	FurnitureKit.rug(h, Vector3(4.3, 0, 7.2), 2.4, 1.1, Color(0.18, 0.22, 0.40))
	FurnitureKit.table(h, Vector3(5.45, 0, 9.65), 0.45, 0.45, 0.5, FurnitureKit.DARK_WOOD)
	FurnitureKit.vase(h, Vector3(5.45, 0.5, 9.65), Color(0.7, 0.7, 0.6))
	FurnitureKit.wardrobe(h, Vector3(0.42, 0, 8.3), 90.0)
	FurnitureKit.table(h, Vector3(6.6, 0, 7.4), 1.0, 0.55, 0.75, FurnitureKit.WOOD, 90.0)
	FurnitureKit.chair(h, Vector3(6.0, 0, 7.4), -90.0)
	FurnitureKit.vase(h, Vector3(6.65, 0.75, 7.1), Color(0.3, 0.5, 0.3))

static func _banyo(h: Node3D) -> void:
	FurnitureKit.bathtub(h, Vector3(10.95, 0, 9.45), 90.0)
	FurnitureKit.toilet(h, Vector3(7.4, 0, 9.4), 90.0)
	FurnitureKit.sink(h, Vector3(11.65, 0, 7.4), -90.0)
	FurnitureKit.rug(h, Vector3(10.9, 0, 8.55), 1.2, 0.6, Color(0.2, 0.45, 0.45))
	FurnitureKit.vase(h, Vector3(11.65, 0.92, 7.15), Color(0.8, 0.5, 0.6))
