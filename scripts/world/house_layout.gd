class_name HouseLayout
## Evin ölçüleri, odaları, duvarları ve kapı boşlukları (metre).
## Kuşbakışı: x sağa (doğu), z aşağı (güney). Ev 12 x 10 m.
##   Salon (kuzeybatı) | Mutfak (kuzeydoğu)
##   ------------ Koridor ------------
##   Yatak odası (güneybatı) | Banyo (güneydoğu)

const WALL_H := 2.6
const DOOR_H := 2.1
const WALL_T := 0.2

const ROOMS := [
	{"name": "Salon", "rect": Rect2(0, 0, 6, 4), "floor": Color(0.34, 0.23, 0.15)},
	{"name": "Mutfak", "rect": Rect2(6, 0, 6, 4), "floor": Color(0.40, 0.44, 0.39)},
	{"name": "Koridor", "rect": Rect2(0, 4, 12, 2), "floor": Color(0.21, 0.14, 0.09)},
	{"name": "Yatak", "rect": Rect2(0, 6, 7, 4), "floor": Color(0.26, 0.28, 0.37)},
	{"name": "Banyo", "rect": Rect2(7, 6, 5, 4), "floor": Color(0.52, 0.60, 0.60)},
]

## axis "z": sabit z çizgisinde x boyunca; axis "x": sabit x çizgisinde z boyunca.
## doors: [başlangıç, bitiş] boşluklar.
const WALLS := [
	{"axis": "z", "at": 0.0, "from": -0.1, "to": 12.1, "doors": [[2.6, 3.6]]},
	{"axis": "z", "at": 10.0, "from": -0.1, "to": 12.1, "doors": []},
	{"axis": "x", "at": 0.0, "from": 0.0, "to": 10.0, "doors": []},
	{"axis": "x", "at": 12.0, "from": 0.0, "to": 10.0, "doors": []},
	{"axis": "z", "at": 4.0, "from": 0.1, "to": 11.9, "doors": [[4.0, 5.0], [9.0, 10.0]]},
	{"axis": "z", "at": 6.0, "from": 0.1, "to": 11.9, "doors": [[2.0, 3.0], [9.0, 10.0]]},
	{"axis": "x", "at": 6.0, "from": 0.1, "to": 3.9, "doors": [[1.5, 2.5]]},
	{"axis": "x", "at": 7.0, "from": 6.1, "to": 9.9, "doors": []},
]

const EXIT_DOOR := Vector3(3.1, 0.0, 0.0)
const PLAYER_SPAWN := Vector3(3.1, 0.05, 1.3)
const PLAYER_SPAWN_YAW := 180.0
