class_name Interactable
extends Node3D
## Bir eşyayı "KULLAN" ile etkileşimli yapar. Hikâye `used` sinyalini dinler.
## enabled = false iken ipucu görünmez ve kullanılamaz.

signal used(player: Node)

var prompt := ""
var enabled := true
var offset := Vector3.ZERO

static func attach(target: Node3D, prompt_text: String, focus_offset: Vector3 = Vector3.ZERO, start_enabled: bool = true) -> Interactable:
	var it := Interactable.new()
	it.name = "Interactable"
	it.prompt = prompt_text
	it.offset = focus_offset
	it.enabled = start_enabled
	target.add_child(it)
	return it

func _ready() -> void:
	add_to_group("interactable")
	set_meta("focus", global_position + offset)

func get_prompt() -> String:
	return prompt if enabled else ""

func interact(player: Node) -> void:
	if enabled:
		used.emit(player)
