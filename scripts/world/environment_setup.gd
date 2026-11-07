class_name EnvironmentSetup
## Karanlık ortam: çok düşük ortam ışığı, siyah arka plan. (Sis ve cila Aşama 5'te.)

static func create(parent: Node) -> WorldEnvironment:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.30, 0.32, 0.42)
	env.ambient_light_energy = 0.12
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	parent.add_child(we)
	return we
