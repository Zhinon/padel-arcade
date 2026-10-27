extends Node3D
## E1 visual laboratory. Ball paths are authored previews, NOT simulated physics.

const PRESETS: Array[Vector3] = [Vector3(0, 10, 18), Vector3(0, 12, 21), Vector3(0, 9, 17)]
const PRESET_NAMES: Array[String] = ["Referencia", "Más atrás", "Más cerca"]
@export_range(35.0, 70.0) var camera_fov: float = 52.0
@export var camera_target := Vector3(0, 0.5, 0)
@export var preview_duration: float = 4.0
var camera: Camera3D
var ball: MeshInstance3D
var ball_shadow: MeshInstance3D
var court: Node3D
var elapsed: float = 0.0
var preview_paused: bool = false
var preset_index: int = 0

func _ready() -> void:
	court = $Court
	camera = $Camera3D
	set_camera_preset(0)
	_build_players()
	ball = _sphere("PreviewBall", 0.105, Color("ddff39"), self)
	var material := ball.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = Color("a1be1d")
	material.emission_energy_multiplier = 0.35
	ball_shadow = _sphere("BallShadow", 0.13, Color(0.01, 0.03, 0.04, 0.65), self)
	ball_shadow.scale = Vector3(1, 0.025, 1)
	_update_preview()
	_update_title()

func _sphere(label: String, radius: float, color: Color, parent: Node3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	return _mesh(label, mesh, color, parent)

func _mesh(label: String, shape: Mesh, color: Color, parent: Node3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = shape
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _build_players() -> void:
	var positions: Array[Vector3] = [Vector3(-2.4, 0, 6.8), Vector3(2.2, 0, 7.6), Vector3(-2.2, 0, -6.3), Vector3(2.5, 0, -7.3)]
	for i in range(positions.size()):
		var player := Node3D.new()
		player.name = "PlayerPlaceholder%d" % (i + 1)
		add_child(player)
		player.position = positions[i]
		var shirt := Color("ed8255") if i < 2 else Color("c8e4ef")
		var torso := CapsuleMesh.new()
		torso.radius = 0.24
		torso.height = 0.7
		var body := _mesh("Shirt", torso, shirt, player)
		body.position.y = 1.15
		var head := _sphere("Head", 0.18, Color("d8ad88"), player)
		head.position.y = 1.72
		for side: float in [-1.0, 1.0]:
			var limb := CapsuleMesh.new()
			limb.radius = 0.095
			limb.height = 0.68
			var leg := _mesh("Leg", limb, Color("223745"), player)
			leg.position = Vector3(side * 0.13, 0.42, 0)
			var arm := _mesh("Arm", limb, shirt, player)
			arm.position = Vector3(side * 0.29, 1.08, -0.03)
			arm.rotation.z = side * 0.25
		var racket := _sphere("Racket", 0.21, Color("d3e457"), player)
		racket.scale = Vector3(0.75, 1.0, 0.12)
		racket.position = Vector3(0.5, 0.85, -0.12)

func set_camera_preset(index: int) -> void:
	preset_index = clampi(index, 0, PRESETS.size() - 1)
	camera.position = PRESETS[preset_index]
	camera.fov = camera_fov
	camera.look_at(camera_target)
	_update_title()

func preview_point(progress: float) -> Vector3:
	return Vector3(3.6 * sin(progress * TAU), 0.12 + 5.7 * sin(progress * PI), lerpf(8.8, -8.8, progress))

func _process(delta: float) -> void:
	if not preview_paused:
		elapsed = fmod(elapsed + delta, preview_duration)
		_update_preview()

func _update_preview() -> void:
	ball.position = preview_point(elapsed / preview_duration)
	ball_shadow.position = Vector3(ball.position.x, 0.022, ball.position.z)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1: set_camera_preset(0)
		KEY_2: set_camera_preset(1)
		KEY_3: set_camera_preset(2)
		KEY_G: court.set_near_wall_ghost(not court.ghost_near_wall)
		KEY_SPACE: preview_paused = not preview_paused
		KEY_R:
			elapsed = 0.0
			_update_preview()

func _update_title() -> void:
	DisplayServer.window_set_title("Pádel · Cámara: %s · 1/2/3 vistas · G vidrio · Espacio pausa · R reinicio · DEMO VISUAL" % PRESET_NAMES[preset_index])
