class_name InputSetup
## Klavye test kısayollarını koddan tanımlar (mobil kontroller asıl kontroldür).

const KEYS := {
	"move_forward": KEY_W,
	"move_back": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"flashlight": KEY_F,
	"interact": KEY_E,
	"run": KEY_SHIFT,
	"pause": KEY_ESCAPE,
	"debug": KEY_F3,
}

static func register() -> void:
	for action in KEYS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = KEYS[action]
		InputMap.action_add_event(action, ev)
