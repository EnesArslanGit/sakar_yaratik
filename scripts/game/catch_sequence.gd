class_name CatchSequence
## Yaratık oyuncuya yetişince oynar.
## İlk yakalamada %50 ihtimalle (oyun başına 1 kez) son anda ayağı takılıp yanına düşer → "KAÇ!" (2 sn).
## Aksi halde: ani korkutma (sarsıntı + kükreme + yüz yakın) → YAKALANDIN ekranı.

static var second_chance_used := false

static func run(m: Monster, p: Player, hud: Hud, screens: Screens) -> void:
	var tree := m.get_tree()
	p.set_cinematic(true)
	var head := m.global_position + Vector3(0, 1.9, 0)
	var dir := head - p.camera.global_position
	var yaw := p.rotation.y + wrapf(atan2(-dir.x, -dir.z) - p.rotation.y, -PI, PI)
	var pitch := atan2(dir.y, Vector2(dir.x, dir.z).length())
	var tw := p.create_tween().set_parallel()
	tw.tween_property(p, "rotation:y", yaw, 0.25)
	tw.tween_property(p.camera, "rotation:x", pitch, 0.25)
	m.look_at(Vector3(p.global_position.x, m.global_position.y, p.global_position.z), Vector3.UP)
	m.body.play("Jump_Start", 1.2, 0.05, true)
	Sfx.play(m, "growl", head, 6.0, 0.85)
	await tree.create_timer(0.45).timeout
	if not second_chance_used and randf() < MonsterConfig.SECOND_CHANCE_PROB:
		second_chance_used = true
		print("[catch] son anda tokezledi")
		await _stumble(m, p, hud)
	else:
		print("[catch] yakalandi")
		await _caught(m, p, hud, screens)

static func _stumble(m: Monster, p: Player, hud: Hud) -> void:
	var tree := m.get_tree()
	var side := m.global_basis.x * (0.9 if randf() < 0.5 else -0.9)
	m.body.play("Death01", 1.6, 0.05, true)
	var tw := m.create_tween()
	tw.tween_property(m, "global_position", m.global_position + side - m.global_basis.z * 0.6, 0.45)
	await tree.create_timer(0.4).timeout
	Sfx.play(m, "thud", m.global_position, 6.0, 0.65)
	p.shake = 0.6
	hud.big_text("KAÇ!", MonsterConfig.SECOND_CHANCE_TIME)
	p.set_cinematic(false)
	await tree.create_timer(MonsterConfig.SECOND_CHANCE_TIME + 0.4).timeout
	m.body.play_backwards("Death01", 1.2)
	await tree.create_timer(m.body.anim_length("Death01") / 1.2).timeout
	m.after_stumble()

static func _caught(m: Monster, p: Player, hud: Hud, screens: Screens) -> void:
	var tree := m.get_tree()
	m.body.play("Punch_Cross", 1.3, 0.05, true)
	var tw := m.create_tween()
	tw.tween_property(m, "global_position", m.global_position.lerp(p.global_position, 0.55), 0.25)
	p.shake = 1.6
	Sfx.play(m, "growl", null, 8.0, 0.7)
	Sfx.play(m, "donk", null, 4.0, 0.5)
	var z := p.create_tween()
	z.tween_property(p.camera, "fov", 42.0, 0.35)
	await tree.create_timer(0.7).timeout
	await hud.fade_to(1.0, 0.35).finished
	await tree.create_timer(0.3).timeout
	screens.show_mode("caught")
