extends Node3D
## Visual blockout and independent, tagged collision surfaces for the E2 lab.

var near_enclosure: Array[MeshInstance3D] = []
var ghost_near_wall: bool = true

func _ready() -> void:
	_build()
	_build_collisions()

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
		# FIP crystal variant: 3 m glass for 4 m at each end.
		# Only the terminal 2 m rise to 4 m with mesh above the glass.
		for sign_z: float in [-1.0, 1.0]:
			_box("SideGlass", Vector3(side_x, 1.5, sign_z * 8), Vector3(0.06, 3, 4), Color(0.5, 0.78, 0.82, 0.08), sign_z > 0.0)
			var corner_center := sign_z * 9.0
			_side_fence(side_x, corner_center - 1.0, corner_center + 1.0, 3.0, 4.0, sign_z > 0.0)
			_box("SideCornerTopRail", Vector3(side_x, 4, corner_center), Vector3(0.055, 0.055, 2), Color("34454d"), sign_z > 0.0)
		for z: float in [-10.0, -8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0, 10.0]:
			var height := 4.0 if absf(z) >= 8.0 else 3.0
			_box("SidePost", Vector3(side_x, height * 0.5, z), Vector3(0.065, height, 0.065), Color("34454d"), z >= 6.0)
		_box("SideBottomRail", Vector3(side_x, 0.12, 0), Vector3(0.055, 0.055, 20), Color("34454d"))
		_box("SideMiddleTopRail", Vector3(side_x, 3, 0), Vector3(0.055, 0.055, 16), Color("34454d"))
		_side_fence(side_x, -6.0, 6.0, 0.0, 3.0)
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

func _side_fence(side_x: float, start_z: float, end_z: float, bottom: float, top: float, near_wall: bool = false) -> void:
	var length := end_z - start_z
	var height := top - bottom
	var center_z := (start_z + end_z) * 0.5
	for i in range(roundi(length / 0.25) + 1):
		_box("SideFence", Vector3(side_x, (bottom + top) * 0.5, start_z + i * 0.25), Vector3(0.012, height, 0.012), Color("56666c"), near_wall)
	for i in range(1, roundi(height / 0.25)):
		_box("SideFenceRow", Vector3(side_x, bottom + i * 0.25, center_z), Vector3(0.012, 0.012, length), Color("56666c"), near_wall)

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


func _surface(label: String, at: Vector3, size: Vector3, kind: String) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 2
	body.set_meta("surface", kind)
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _build_collisions() -> void:
	# Inner surfaces line up with floor boundaries x=±5, z=±10.
	_surface("FloorCollider", Vector3(0, -0.1, 0), Vector3(10, 0.2, 20), "floor")
	for side: float in [-1.0, 1.0]:
		_surface("EndGlassCollider", Vector3(0, 1.5, side * 10.06), Vector3(10.24, 3, 0.12), "glass")
		_surface("EndFenceCollider", Vector3(0, 3.5, side * 10.06), Vector3(10.24, 1, 0.12), "fence")
		for end: float in [-1.0, 1.0]:
			_surface("SideGlassCollider", Vector3(side * 5.06, 1.5, end * 8), Vector3(0.12, 3, 4), "glass")
			_surface("CornerFenceCollider", Vector3(side * 5.06, 3.5, end * 9), Vector3(0.12, 1, 2), "fence")
		_surface("MiddleFenceCollider", Vector3(side * 5.06, 1.5, 0), Vector3(0.12, 3, 12), "fence")
		_surface("NetPostCollider", Vector3(side * 5, 0.5, 0), Vector3(0.1, 1, 0.1), "net")
	# Short panels follow the top cord rather than one uniform-height wall.
	for i in range(20):
		var x := -4.75 + i * 0.5
		var height := 0.88 + 0.04 * absf(x) / 5.0
		_surface("NetCollider", Vector3(x, height * 0.5, 0), Vector3(0.5, height, 0.025), "net")
