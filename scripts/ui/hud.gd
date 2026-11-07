class_name Hud
extends Control
## Ekran bilgileri: nişangâh, etkileşim ipucu ("KULLAN: Kapıyı aç"), görev yazısı (sol üst),
## alt yazı (ortada, hikâye cümleleri), kararma perdesi (fade), dayanıklılık barı.

var player: Player
var monster: Monster
var fade := 1.0                 # 1 = tam siyah
var keys := -1                  # -1 = sayaç gizli
var hiding := false
var debug := false
var danger := 0.0               # 0..1 yaratık yakınlığı (kenar kararması)
var _pings: Array = []          # [dünya konumu, kalan süre]
var _big := ""
var _big_time := 0.0
var objective := ""
var _caption := ""
var _caption_time := 0.0
var _obj_flash := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	add_to_group("hud")

## Yaratığın sakarlık gürültüsü: ekranın üstünde yönünü gösteren işaret (2 sn).
func ping(world_pos: Vector3) -> void:
	_pings.append([world_pos, 2.0])

func big_text(text: String, seconds: float) -> void:
	_big = text
	_big_time = seconds

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and not OS.has_feature("mobile"):
		debug = not debug

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
	_big_time = maxf(_big_time - delta, 0.0)
	for pg in _pings:
		pg[1] -= delta
	_pings = _pings.filter(func(pg): return pg[1] > 0.0)
	var target_danger := 0.0
	if monster and monster.visible and player:
		target_danger = clampf(1.0 - monster.global_position.distance_to(player.global_position) / 8.0, 0.0, 1.0)
	danger = lerpf(danger, target_danger, clampf(delta * 3.0, 0.0, 1.0))
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
	_draw_vignette(s)
	if hiding:
		var slit := s.x * 0.09
		draw_rect(Rect2(0, 0, s.x / 2 - slit / 2, s.y), Color(0.02, 0.015, 0.01, 0.97))
		draw_rect(Rect2(s.x / 2 + slit / 2, 0, s.x / 2 - slit / 2, s.y), Color(0.02, 0.015, 0.01, 0.97))
	_draw_pings(s, font)
	if keys >= 0:
		var kt := "Anahtar parçası: %d / 3" % keys
		var kw := font.get_string_size(kt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_rect(Rect2(s.x - kw - 40, 14, kw + 24, 40), Color(0, 0, 0, 0.45))
		draw_string(font, Vector2(s.x - kw - 28, 42), kt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 0.85, 0.45))
	if _big_time > 0.0:
		_center_text(font, _big, Vector2(s.x / 2, s.y * 0.4), 96, Color(1, 0.3, 0.25, clampf(_big_time * 2.0, 0.0, 1.0)))
	if debug and monster:
		var d := "Yaratık: %s | hız %.1f | görüyor %s | sakarlık arası %.1f | son: %s" % [monster.state_name(), monster.velocity.length(), monster.sees_player, monster.clumsy.gap, monster.clumsy.last_event]
		draw_string(font, Vector2(20, s.y - 70), d, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.6, 1, 0.6))
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

## Yaratık yaklaştıkça ekran kenarları kararır.
func _draw_vignette(s: Vector2) -> void:
	var a := 0.15 + danger * 0.6
	var steps := 10
	for i in steps:
		var k := float(i) / steps
		var w := s.x * 0.18 * (1.0 - k)
		var h := s.y * 0.2 * (1.0 - k)
		var c := Color(0, 0, 0, a / steps * 1.6)
		draw_rect(Rect2(0, 0, w, s.y), c)
		draw_rect(Rect2(s.x - w, 0, w, s.y), c)
		draw_rect(Rect2(0, 0, s.x, h), c)
		draw_rect(Rect2(0, s.y - h, s.x, h), c)

## Gürültü işareti: ekranın üst kenarında, sese doğru dönmüş ok + "!" .
func _draw_pings(s: Vector2, font: Font) -> void:
	if player == null:
		return
	for pg in _pings:
		var to: Vector3 = pg[0] - player.global_position
		var fwd := -player.global_basis.z
		var right := player.global_basis.x
		var ang := atan2(to.dot(right), to.dot(fwd))
		var a := clampf(pg[1], 0.0, 1.0)
		var center := s / 2 + Vector2(sin(ang), -cos(ang)) * minf(s.x, s.y) * 0.38
		var tip := center + Vector2(sin(ang), -cos(ang)) * 28.0
		var side := Vector2(cos(ang), sin(ang)) * 16.0
		draw_colored_polygon(PackedVector2Array([tip, center + side, center - side]), Color(1, 0.85, 0.3, 0.85 * a))
		_center_text(font, "!", center - Vector2(sin(ang), -cos(ang)) * 26.0 + Vector2(0, 10), 34, Color(1, 0.85, 0.3, a))
