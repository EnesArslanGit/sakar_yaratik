class_name Hud
extends Control
## Ekran bilgileri: nişangâh, etkileşim ipucu ("KULLAN: Kapıyı aç"), görev yazısı (sol üst),
## alt yazı (ortada, hikâye cümleleri), kararma perdesi (fade), dayanıklılık barı.

var player: Player
var fade := 1.0                 # 1 = tam siyah
var objective := ""
var _caption := ""
var _caption_time := 0.0
var _obj_flash := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

func set_objective(text: String) -> void:
	objective = text
	_obj_flash = 2.0

func caption(text: String, seconds: float = 3.0) -> void:
	_caption = text
	_caption_time = seconds

func fade_to(value: float, seconds: float) -> Tween:
	var tw := create_tween()
	tw.tween_property(self, "fade", value, seconds)
	return tw

func _process(delta: float) -> void:
	_caption_time = maxf(_caption_time - delta, 0.0)
	_obj_flash = maxf(_obj_flash - delta, 0.0)
	queue_redraw()

func _draw() -> void:
	var s := size
	var font := ThemeDB.fallback_font
	if player and not player.cinematic:
		draw_circle(s / 2, 2.5, Color(1, 1, 1, 0.5))
		if player.target:
			var key := "KULLAN" if OS.has_feature("mobile") else "E / KULLAN"
			_center_text(font, "%s:  %s" % [key, player.target.get_prompt()], s / 2 + Vector2(0, 60), 24, Color(1, 1, 1, 0.9))
	if player and player.stamina < Player.STAMINA_MAX:
		var w := 260.0
		var pos := Vector2(s.x / 2 - w / 2, s.y - 40)
		var ratio := player.stamina / Player.STAMINA_MAX
		var col := Color(0.9, 0.3, 0.25, 0.8) if player.exhausted else Color(0.95, 0.85, 0.5, 0.75)
		draw_rect(Rect2(pos, Vector2(w, 10)), Color(0, 0, 0, 0.5))
		draw_rect(Rect2(pos, Vector2(w * ratio, 10)), col)
	if fade > 0.0:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0, 0, 0, fade))
	if objective != "":
		var glow := 0.25 + 0.5 * _obj_flash / 2.0
		draw_rect(Rect2(14, 14, font.get_string_size(objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x + 24, 40), Color(0, 0, 0, 0.45))
		draw_string(font, Vector2(26, 42), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 0.92, 0.7, 0.75 + glow))
	if _caption_time > 0.0:
		var a := clampf(_caption_time / 0.6, 0.0, 1.0)
		_center_text(font, _caption, Vector2(s.x / 2, s.y * 0.78), 30, Color(1, 1, 1, a))

func _center_text(font: Font, text: String, center: Vector2, fs: int, c: Color) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, center + Vector2(-w / 2 + 2, 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, c.a * 0.8))
	draw_string(font, center + Vector2(-w / 2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)
