class_name Hud
extends Control
## Ekran bilgileri: orta nişangâh noktası, dayanıklılık barı, bilgisayar için kısa kontrol ipucu.

var player: Player
var _hint_time := 10.0

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	_hint_time = maxf(_hint_time - delta, 0.0)
	queue_redraw()

func _draw() -> void:
	var s := size
	draw_circle(s / 2, 2.5, Color(1, 1, 1, 0.5))
	if player and player.stamina < Player.STAMINA_MAX:
		var w := 260.0
		var pos := Vector2(s.x / 2 - w / 2, s.y - 40)
		var ratio := player.stamina / Player.STAMINA_MAX
		var col := Color(0.9, 0.3, 0.25, 0.8) if player.exhausted else Color(0.95, 0.85, 0.5, 0.75)
		draw_rect(Rect2(pos, Vector2(w, 10)), Color(0, 0, 0, 0.5))
		draw_rect(Rect2(pos, Vector2(w * ratio, 10)), col)
	if _hint_time > 0.0 and not OS.has_feature("mobile"):
		var a := clampf(_hint_time / 2.0, 0.0, 1.0)
		var t := "WASD: yürü   Sağ tık: fareyle bak (tekrar sağ tık: bırak)   F: fener   Shift: koş   E: kullan"
		draw_string(ThemeDB.fallback_font, Vector2(20, 34), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.75 * a))
