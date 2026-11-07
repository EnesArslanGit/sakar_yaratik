extends Node3D
## Oyunun giriş noktası. Her şeyi koddan kurar.
## Aşama 0: sadece iskelet. Sonraki aşamalarda ev, oyuncu, yaratık buradan eklenecek.

func _ready() -> void:
	InputSetup.register()
	var label := Label.new()
	label.text = "Sakar Yaratık — kurulum tamam"
	label.add_theme_font_size_override("font_size", 32)
	var layer := CanvasLayer.new()
	layer.add_child(label)
	add_child(layer)
	print("[main] hazir")
