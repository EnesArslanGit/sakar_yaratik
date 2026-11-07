extends Node3D
## Oyunun giriş noktası. Ortamı, evi, oyuncuyu ve arayüzü koddan kurar.
## Test için komut satırı (-- sonrası): pose=x,z,açı  shot=C:/yol.png  (ekran görüntüsü alıp kapanır)

var player: Player

func _ready() -> void:
	InputSetup.register()
	EnvironmentSetup.create(self)
	HouseBuilder.build(self)
	player = Player.new()
	player.name = "Player"
	player.position = HouseLayout.PLAYER_SPAWN
	player.rotation_degrees.y = HouseLayout.PLAYER_SPAWN_YAW
	add_child(player)
	_build_ui()
	_handle_test_args()
	print("[main] hazir")

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud := Hud.new()
	hud.player = player
	layer.add_child(hud)
	var controls := TouchControls.new()
	layer.add_child(controls)
	player.set_controls(controls)

func _handle_test_args() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("pose="):
			var p := a.substr(5).split(",")
			player.position = Vector3(float(p[0]), 0.05, float(p[1]))
			player.rotation_degrees.y = float(p[2])
			if p.size() > 3:
				player.camera.rotation_degrees.x = float(p[3])
		elif a.begins_with("shot="):
			_take_shot(a.substr(5))

func _take_shot(path: String) -> void:
	for i in 40:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(path)
	print("[main] goruntu: ", path)
	get_tree().quit()
