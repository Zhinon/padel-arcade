extends Node3D
## E2 physics lab; authored E1 trajectory is retained only for camera checks.

const PRESETS: Array[Vector3] = [Vector3(0, 10, 18), Vector3(0, 12, 21), Vector3(0, 9, 17)]
const PRESET_NAMES: Array[String] = ["Referencia", "Más atrás", "Más cerca"]
@export_range(35.0, 70.0) var camera_fov: float = 52.0
@export var camera_target := Vector3(0, 0.5, 0)
@export var preview_duration: float = 4.0
const BALL_SIM = preload("res://scripts/ball_simulation.gd")
const SCENARIOS = preload("res://scripts/launch_scenarios.gd")
var simulation: CharacterBody3D
var scenarios: Array[Dictionary] = SCENARIOS.all()
var scenario_index: int = 1
var launch_seed: int = 42
var camera_preview: bool = false
var repeat_launch: bool = false
var resting_notified: bool = false
var trail: MeshInstance3D
var trail_points: Array[Vector3] = []
var contact_markers: Array[MeshInstance3D] = []
var trail_tick: int = 0
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
	simulation = BALL_SIM.new()
	simulation.name = "BallSimulation"
	add_child(simulation)
	simulation.contacted.connect(_on_contact)
	simulation.launched.connect(_clear_contact_markers)
	trail = MeshInstance3D.new()
	trail.name = "BallTrail"
	var trail_material := StandardMaterial3D.new()
	trail_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_material.albedo_color = Color("a6c85a")
	trail.material_override = trail_material
	add_child(trail)
	camera_preview = "--camera-preview" in OS.get_cmdline_user_args()
	if camera_preview:
		enable_camera_preview()
	else:
		var initial_scenario := 1
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--scenario="):
				initial_scenario = clampi(arg.trim_prefix("--scenario=").to_int() - 1, 0, scenarios.size() - 1)
		launch_scenario(initial_scenario)
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
	if camera_preview:
		if not preview_paused:
			elapsed = fmod(elapsed + delta, preview_duration)
			_update_preview()
	else:
		ball.position = simulation.position
		ball_shadow.position = Vector3(ball.position.x, 0.022, ball.position.z)
		ball_shadow.visible = ball.position.y >= 0.0 and absf(ball.position.x) <= 5.0 and absf(ball.position.z) <= 10.0

func _physics_process(_delta: float) -> void:
	if camera_preview or preview_paused:
		return
	if simulation.grounded and simulation.velocity.is_zero_approx() and not resting_notified:
		_update_title("detenida")
		resting_notified = true
	trail_tick += 1
	if trail_tick % 4 == 0:
		trail_points.append(simulation.position)
		if trail_points.size() > 100:
			trail_points.pop_front()
		var mesh := ImmediateMesh.new()
		if trail_points.size() > 1:
			mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			for point: Vector3 in trail_points:
				mesh.surface_add_vertex(point)
			mesh.surface_end()
		trail.mesh = mesh
	if repeat_launch and (simulation.elapsed > 6.0 or simulation.position.y < -3.0):
		launch_scenario(scenario_index)

func enable_camera_preview() -> void:
	camera_preview = true
	simulation.active = false
	trail.visible = false
	_update_preview()

func launch_scenario(index: int) -> void:
	camera_preview = false
	preview_paused = false
	scenario_index = clampi(index, 0, scenarios.size() - 1)
	var scenario := scenarios[scenario_index]
	resting_notified = false
	simulation.launch(scenario.position, scenario.velocity, launch_seed)
	trail_points.clear()
	trail.mesh = null
	trail.visible = true
	ball.position = simulation.position
	ball_shadow.position = Vector3(ball.position.x, 0.022, ball.position.z)
	_update_title()

func _clear_contact_markers() -> void:
	for marker: MeshInstance3D in contact_markers:
		marker.queue_free()
	contact_markers.clear()

func _on_contact(event: Dictionary) -> void:
	_update_title("%s #%d" % [event.surface, event.sequence])
	var colors := {"floor": Color("67e3ed"), "glass": Color("a3f59b"), "fence": Color("f2ac59"), "net": Color("f56d78")}
	var marker := _sphere("ContactMarker", 0.055, colors.get(event.surface, Color.WHITE), self)
	marker.position = event.position + event.normal * 0.02
	contact_markers.append(marker)
	if contact_markers.size() > 20:
		contact_markers.pop_front().queue_free()

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
		KEY_SPACE:
			preview_paused = not preview_paused
			simulation.active = not preview_paused and not camera_preview
		KEY_R:
			if camera_preview:
				elapsed = 0.0
				_update_preview()
			else:
				launch_scenario(scenario_index)
		KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7:
			launch_scenario(event.physical_keycode - KEY_F1)
		KEY_N:
			launch_seed += 1
			launch_scenario(scenario_index)
		KEY_L:
			repeat_launch = not repeat_launch
			_update_title()

func _update_title(last_contact: String = "—") -> void:
	if camera_preview:
		DisplayServer.window_set_title("Pádel · Prueba visual de cámara · 1/2/3 vistas · G vidrio · Espacio pausa · R reinicio")
	else:
		DisplayServer.window_set_title("Pádel · F%d %s · contacto %s · semilla %d · F1–F7 pruebas · N variar reja · Espacio pausa · R relanzar · L repetir %s" % [scenario_index + 1, scenarios[scenario_index].name, last_contact, launch_seed, "sí" if repeat_launch else "no"])
