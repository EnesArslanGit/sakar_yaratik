class_name Screens
extends Control
## Tam ekran menüler: ana menü, duraklatma, YAKALANDIN, DEMO BİTTİ.
## Açıkken oyun duraklar (get_tree().paused). Butonlar hem dokunmatik hem fareyle çalışır.

signal start_pressed
signal retry_pressed
signal restart_pressed

var mode := ""
var _title: Label
var _sub: Label
var _box: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.82)
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(center)
	_box = VBoxContainer.new()
	_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_theme_constant_override("separation", 22)
	center.add_child(_box)
	_title = _label(64)
	_sub = _label(24)
	hide()

func _label(fs: int) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	_box.add_child(l)
	return l

func _clear_buttons() -> void:
	for c in _box.get_children():
		if c is Button:
			c.queue_free()

func _button(text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 80)
	b.add_theme_font_size_override("font_size", 30)
	b.pressed.connect(cb)
	_box.add_child(b)

func show_mode(m: String, extra: String = "") -> void:
	mode = m
	_clear_buttons()
	match m:
		"menu":
			_title.text = "SAKAR YARATIK"
			_sub.text = "Gece 03:07. Evde yalnız değilsin... ama o pek becerikli sayılmaz."
			_button("BAŞLA", func(): _close(); start_pressed.emit())
		"pause":
			_title.text = "DURAKLATILDI"
			_sub.text = ""
			_button("DEVAM", _close)
			_button("BAŞTAN BAŞLA", func(): _close(); restart_pressed.emit())
		"caught":
			_title.text = "YAKALANDIN"
			_title.add_theme_color_override("font_color", Color(0.9, 0.25, 0.2))
			_sub.text = "Sakar olabilir... ama yine de seni yakaladı."
			_button("TEKRAR DENE", func(): _close(); retry_pressed.emit())
		"win":
			_title.text = "DEMO BİTTİ"
			_title.add_theme_color_override("font_color", Color(0.6, 1.0, 0.5))
			_sub.text = "Kaçmayı başardın! %s" % extra
			_button("TEKRAR OYNA", func(): _close(); restart_pressed.emit())
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close() -> void:
	hide()
	_title.remove_theme_color_override("font_color")
	_title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	get_tree().paused = false
	mode = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if mode == "pause":
			_close()
		elif mode == "":
			show_mode("pause")
