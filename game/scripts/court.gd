extends Node3D
## Court blockout: visual geometry only; collision and gameplay follow in E2.

var near_enclosure: Array[MeshInstance3D] = []
var ghost_near_wall: bool = true

func _ready() -> void:
	_build()

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _box(label: String, at: Vector3, size: Vector3, color: Color, near_wall: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = at
	add_child(instance)
	if near_wall:
		near_enclosure.append(instance)
	return instance

func _build() -> void:
	_box("Surround", Vector3(0, -0.22, 0), Vector3(34, 0.3, 40), Color("182c32"))
	_box("CourtFloor", Vector3(0, -0.05, 0), Vector3(10, 0.1, 20), Color("0e6089"))
	var white := Color("eef4ed")
	for x: float in [-4.975, 4.975]:
		_box("Sideline", Vector3(x, 0.007, 0), Vector3(0.05, 0.012, 20), white)
	for z: float in [-9.975, 9.975, -6.95, 6.95]:
		_box("CourtLine", Vector3(0, 0.009, z), Vector3(10, 0.014, 0.05), white)
	for sign_z: float in [-1.0, 1.0]:
		_box("ServiceCenter", Vector3(0, 0.01, sign_z * 3.575), Vector3(0.05, 0.014, 7.15), white)
		var near_wall := sign_z > 0.0
		var wall_z := sign_z * 10.06
		_box("BackGlass", Vector3(0, 1.5, wall_z), Vector3(10, 3, 0.06), Color(0.5, 0.78, 0.82, 0.09), near_wall)
		for x: float in [-5.06, -2.5, 0.0, 2.5, 5.06]:
			_box("EndPost", Vector3(x, 2, wall_z), Vector3(0.065, 4, 0.065), Color("34454d"), near_wall)
		for y: float in [0.12, 3.0, 4.0]:
			_box("EndRail", Vector3(0, y, wall_z), Vector3(10.16, 0.055, 0.055), Color("34454d"), near_wall)
		for i in range(41):
			_box("EndFence", Vector3(-5.0 + i * 0.25, 3.5, wall_z), Vector3(0.012, 1, 0.012), Color("56666c"), near_wall)
		for y: float in [3.25, 3.5, 3.75]:
			_box("EndFenceRow", Vector3(0, y, wall_z), Vector3(10, 0.012, 0.012), Color("56666c"), near_wall)
	for sign_x: float in [-1.0, 1.0]:
		var side_x := sign_x * 5.06
		for sign_z: float in [-1.0, 1.0]:
			# Simplified side panels; access openings remain a later blockout refinement.
			_box("SideGlass", Vector3(side_x, 1.5, sign_z * 8), Vector3(0.06, 3, 4), Color(0.5, 0.78, 0.82, 0.08), sign_z > 0.0)
		for z: float in [-10.0, -8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0, 10.0]:
			_box("SidePost", Vector3(side_x, 1.5, z), Vector3(0.065, 3, 0.065), Color("34454d"), z >= 6.0)
		for y: float in [0.12, 3.0]:
			_box("SideRail", Vector3(side_x, y, 0), Vector3(0.055, 0.055, 20), Color("34454d"))
		for i in range(49):
			_box("SideFence", Vector3(side_x, 1.5, -6.0 + i * 0.25), Vector3(0.012, 3, 0.012), Color("56666c"))
		for i in range(1, 12):
			_box("SideFenceRow", Vector3(side_x, i * 0.25, 0), Vector3(0.012, 0.012, 12), Color("56666c"))
	for x: float in [-5.0, 5.0]:
		_box("NetPost", Vector3(x, 0.5, 0), Vector3(0.1, 1.0, 0.1), Color("e7efec"))
	# Top edge follows the 0.88 m center / 0.92 m end reference with short segments.
	for i in range(40):
		var x := -4.875 + i * 0.25
		var top := 0.88 + 0.04 * absf(x) / 5.0
		_box("NetCord", Vector3(x, top, 0), Vector3(0.252, 0.04, 0.025), white)
		_box("NetVertical", Vector3(x, top * 0.5, 0), Vector3(0.012, top, 0.012), Color("182b32"))
	for i in range(1, 9):
		_box("NetHorizontal", Vector3(0, i * 0.1, 0), Vector3(10, 0.012, 0.012), Color("182b32"))
	set_near_wall_ghost(true)

func set_near_wall_ghost(enabled: bool) -> void:
	ghost_near_wall = enabled
	for instance: MeshInstance3D in near_enclosure:
		# Transparent geometry stays drawn, so the rear enclosure is still perceptible.
		var material := instance.material_override as StandardMaterial3D
		if not material.has_meta("original_alpha"):
			material.set_meta("original_alpha", material.albedo_color.a)
		var color := material.albedo_color
		color.a = float(material.get_meta("original_alpha")) * (0.12 if enabled else 1.0)
		material.albedo_color = color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if color.a < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if enabled else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
