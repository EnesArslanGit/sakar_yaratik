extends Node3D
## Oyunun giriş noktası. Ortamı, evi, oyuncuyu, arayüzü ve hikâyeyi koddan kurar.
## Test için komut satırı (-- sonrası):
##   pose=x,z,yaw[,pitch]  hikâyeyi atla, oyuncuyu oraya koy     light   feneri ver
##   story=wash            doğrudan yüz yıkama/korku sahnesi       wait=sn ekran görüntüsünden önce bekle
##   shot=C:/yol.png       ekran görüntüsü alıp kapan

var player: Player
var hud: Hud
var story: Story
var env: WorldEnvironment

func _ready() -> void:
	InputSetup.register()
	env = EnvironmentSetup.create(self)
	HouseBuilder.build(self)
	player = Player.new()
	player.name = "Player"
	player.position = HouseLayout.PLAYER_SPAWN
	player.rotation_degrees.y = HouseLayout.PLAYER_SPAWN_YAW
	add_child(player)
	_build_ui()
	story = Story.new()
	story.name = "Story"
	add_child(story)
	story.setup(player, hud, env.environment)
	if not _handle_test_args():
		story.start()
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
