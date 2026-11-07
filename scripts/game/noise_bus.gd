class_name NoiseBus
## Gürültü sistemi: bir şey ses çıkarınca (oyuncu koşar, kapı açılır, eşya kırılır) dinleyenlere haber verir.
## Yaratık dinler; oyuncunun koşması onu çeker.

static var listeners: Array = []

static func emit(pos: Vector3, radius: float, source: String = "") -> void:
	for l in listeners:
		if is_instance_valid(l):
			l.hear(pos, radius, source)

static func add(listener: Object) -> void:
	if not listeners.has(listener):
		listeners.append(listener)

static func remove(listener: Object) -> void:
	listeners.erase(listener)
