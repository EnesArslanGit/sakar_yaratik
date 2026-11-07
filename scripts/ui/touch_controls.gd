class_name TouchControls
extends Control
## Mobil kontroller: sol yarı = sanal joystick (dokunduğun yerde açılır),
## sağ yarı = parmak kaydırarak bakış, sağ altta butonlar (KOŞ, KULLAN, FENER).
## Çoklu dokunma destekler. Bilgisayarda fareyle tıklama dokunma gibi çalışır.

signal flashlight_pressed
signal interact_pressed

const JOY_RADIUS := 85.0
const JOY_ZONE := 0.45   # ekranın sol %45'i joystick alanı

var move_vector := Vector2.ZERO
var run_held := false
var flash_on := true
var show_flash := false   # fener bulununca görünür

var _look_delta := Vector2.ZERO
var _joy_index := -1
var _joy_center := Vector2.ZERO
var _joy_knob := Vector2.ZERO
var _look_index := -1
var _btn_touch := {}   # dokunma no -> buton adı

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func consume_look() -> Vector2:
	var d := _look_delta
	_look_delta = Vector2.ZERO
	return d

func _buttons() -> Dictionary:
	var s := size
	var b := {
		"run": {"pos": Vector2(s.x - 125, s.y - 135), "r": 72.0, "text": "KOŞ"},
		"interact": {"pos": Vector2(s.x - 290, s.y - 90), "r": 58.0, "text": "KULLAN"},
	}
	if show_flash:
		b["flashlight"] = {"pos": Vector2(s.x - 125, s.y - 310), "r": 52.0, "text": "FENER"}
	return b

func _joy_rest() -> Vector2:
	return Vector2(170, size.y - 170)

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.index, event.position)
		else:
			_on_release(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == _joy_index:
			_move_joy(event.position)
			queue_redraw()
		elif event.index == _look_index:
			_look_delta += event.relative

func _on_press(idx: int, pos: Vector2) -> void:
	var btns := _buttons()
	for key in btns:
		var b: Dictionary = btns[key]
		if pos.distance_to(b["pos"]) <= b["r"] * 1.15:
			_btn_touch[idx] = key
			match key:
				"run": run_held = true
				"flashlight": flashlight_pressed.emit()
				"interact": interact_pressed.emit()
			return
	if pos.x < size.x * JOY_ZONE and _joy_index == -1:
		_joy_index = idx
		_joy_center = pos
		_joy_knob = pos
		move_vector = Vector2.ZERO
	elif _look_index == -1:
		_look_index = idx

func _on_release(idx: int) -> void:
	if idx == _joy_index:
		_joy_index = -1
		move_vector = Vector2.ZERO
	if idx == _look_index:
		_look_index = -1
	if _btn_touch.has(idx):
		if _btn_touch[idx] == "run":
			run_held = false
		_btn_touch.erase(idx)

func _move_joy(pos: Vector2) -> void:
	var off := pos - _joy_center
	if off.length() > JOY_RADIUS:
		_joy_center = pos - off.normalized() * JOY_RADIUS
		off = pos - _joy_center
	_joy_knob = pos
	move_vector = off / JOY_RADIUS

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var active := _joy_index != -1
	var c := _joy_center if active else _joy_rest()
	var k := _joy_knob if active else _joy_rest()
	draw_circle(c, JOY_RADIUS, Color(1, 1, 1, 0.08 if not active else 0.14))
	draw_arc(c, JOY_RADIUS, 0, TAU, 48, Color(1, 1, 1, 0.3), 3.0, true)
	draw_circle(k, 38.0, Color(1, 1, 1, 0.35 if active else 0.2))
	var btns := _buttons()
	var pressed := _btn_touch.values()
	for key in btns:
		var b: Dictionary = btns[key]
		var on: bool = pressed.has(key) or (key == "flashlight" and flash_on)
		var fill := Color(1, 0.9, 0.6, 0.32) if on else Color(1, 1, 1, 0.12)
		draw_circle(b["pos"], b["r"], fill)
		draw_arc(b["pos"], b["r"], 0, TAU, 48, Color(1, 1, 1, 0.45), 3.0, true)
		var fs := 22 if key != "interact" else 18
		var tw := font.get_string_size(b["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(font, b["pos"] + Vector2(-tw / 2, fs * 0.35), b["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, 0.85))
