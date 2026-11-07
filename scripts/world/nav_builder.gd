class_name NavBuilder
## Yaratığın yol bulması için navigasyon ağını ev kurulduktan sonra koddan çıkarır (bake).
## Kaynak: "nav_source" grubundaki düğümlerin statik çarpışmaları (katman 1). İç kapılar katman 2'de
## olduğu için ağı kesmez; yaratık kapalı kapıya gelince açar.

static func build(root: Node3D, house: Node3D) -> NavigationRegion3D:
	house.add_to_group("nav_source")
	var nm := NavigationMesh.new()
	nm.cell_size = 0.1
	nm.cell_height = 0.1
	nm.agent_radius = 0.4
	nm.agent_height = 1.6
	nm.agent_max_climb = 0.2
	nm.agent_max_slope = 30.0
	nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nm.geometry_collision_mask = 1
	nm.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	nm.geometry_source_group_name = &"nav_source"
	var region := NavigationRegion3D.new()
	region.name = "Navigation"
	region.navigation_mesh = nm
	root.add_child(region)
	region.bake_navigation_mesh(false)
	return region
