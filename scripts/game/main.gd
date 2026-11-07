extends Node3D
## Oyunun giriş noktası. Ortamı, evi, oyuncuyu, arayüzü ve hikâyeyi koddan kurar.
## Test için komut satırı (-- sonrası):
##   pose=x,z,yaw[,pitch]  hikâyeyi atla, oyuncuyu oraya koy     light   feneri ver
##   story=wash            doğrudan yüz yıkama/korku sahnesi       wait=sn ekran görüntüsünden önce bekle
##   story=dark            doğrudan karanlık bölüm (yaratık + anahtarlar)   debug  F3 bilgisini aç
##   shot=C:/yol.png       ekran görüntüsü alıp kapan

var player: Player
var hud: Hud
var story: Story
var env: WorldEnvironment
var monster: Monster
var keys: KeyHunt
var screens: Screens

func _ready() -> void:
	InputSetup.register()
	env = EnvironmentSetup.create(self)
	var house := HouseBuilder.build(self)
	NavBuilder.build(self, house)
	player = Player.new()
	player.name = "Player"
	player.position = HouseLayout.PLAYER_SPAWN
	player.rotation_degrees.y = HouseLayout.PLAYER_SPAWN_YAW
	add_child(player)
	monster = Monster.new()
	monster.name = "Monster"
	monster.player = player
	add_child(monster)
	keys = KeyHunt.new()
	add_child(keys)
	_build_ui()
	hud.monster = monster
	var hide := HideSpot.new()
	add_child(hide)
	hide.setup(player, hud, monster)
	story = Story.new()
	story.name = "Story"
	add_child(story)
	story.setup(player, hud, env.environment, monster, keys, screens)
	if not _handle_test_args():
		story.begin()
	print("[main] hazir")

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.player = player
	layer.add_child(hud)
	var controls := TouchControls.new()
	layer.add_child(controls)
	player.set_controls(controls)
	controls.pause_pressed.connect(func(): if screens.mode == "": screens.show_mode("pause"))
	screens = Screens.new()
	layer.add_child(screens)

## Test argümanı varsa true döner (hikâye başlatılmaz).
func _handle_test_args() -> bool:
	var args := OS.get_cmdline_user_args()
	var test := false
	var wait := 0.7
	var shot := ""
	for a in args:
		if a.begins_with("pose="):
			test = true
			hud.fade = 0.0
			var p := a.substr(5).split(",")
			player.position = Vector3(float(p[0]), 0.05, float(p[1]))
			player.rotation_degrees.y = float(p[2])
			if p.size() > 3:
				player.camera.rotation_degrees.x = float(p[3])
		elif a == "light":
			player.give_flashlight()
		elif a == "story=wash":
			test = true
			story.debug_wash.call_deferred()
		elif a == "story=dark":
			test = true
			story.debug_dark.call_deferred()
		elif a == "story=win":
			test = true
			story.debug_win.call_deferred()
		elif a == "debug":
			hud.debug = true
		elif a == "log":
			_log_loop()
		elif a == "menu":
			test = true
			story.begin.call_deferred()
		elif a.begins_with("monster="):
			var mb := MonsterBody.new()
			add_child(mb)
			var mp := a.substr(8).split(",")
			mb.position = Vector3(float(mp[1]), 0.0, float(mp[2])) if mp.size() > 2 else Vector3(3.0, 0.0, 2.6)
			mb.rotation_degrees.y = float(mp[3]) if mp.size() > 3 else 0.0
			mb.play(mp[0])
		elif a.begins_with("wait="):
			wait = float(a.substr(5))
		elif a.begins_with("shot="):
			shot = a.substr(5)
	if shot != "":
		_take_shot(shot, wait)
	return test

func _take_shot(path: String, wait: float) -> void:
	await get_tree().create_timer(wait).timeout
	get_viewport().get_texture().get_image().save_png(path)
	print("[main] goruntu: ", path)
	get_tree().quit()

## Test: yaratığın durumunu konsola yazar.
func _log_loop() -> void:
	while true:
		await get_tree().create_timer(0.5).timeout
		print("[log] t=%.1f yaratik=%s pos=(%.1f,%.1f) hiz=%.1f gor=%s sakar=%s oyuncu=(%.1f,%.1f) sinema=%s ekran=%s" % [Time.get_ticks_msec() / 1000.0, monster.state_name(), monster.global_position.x, monster.global_position.z, monster.velocity.length(), monster.sees_player, monster.clumsy.last_event, player.global_position.x, player.global_position.z, player.cinematic, screens.mode])
