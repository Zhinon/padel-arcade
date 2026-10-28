extends Node3D
## E3 practice session; E2 lab and E1 camera checks remain explicitly selectable.

const PRESETS: Array[Vector3] = [Vector3(0, 10, 18), Vector3(0, 12, 21), Vector3(0, 9, 17)]
const PRESET_NAMES: Array[String] = ["Referencia", "Más atrás", "Más cerca"]
@export_range(35.0, 70.0) var camera_fov: float = 52.0
@export var camera_target := Vector3(0, 0.5, 0)
@export var preview_duration: float = 4.0
const BALL_SIM = preload("res://scripts/ball_simulation.gd")
const PLAYER_MOTOR = preload("res://scripts/player_motor.gd")
const PRACTICE_INPUT = preload("res://scripts/practice_input.gd")
const BASIC_SHOT = preload("res://scripts/basic_shot.gd")
const IMPACT_FEEDBACK = preload("res://scripts/impact_feedback.gd")
const PRACTICE_HUD = preload("res://scripts/practice_hud.gd")
var controlled_player: CharacterBody3D
var input_adapter: Node
var shot_controller: Node
var impact_feedback: Node3D
var hud: CanvasLayer
var practice_mode: bool = false
var resume_ball_active: bool = false
var feed_lane: int = 0
var aim_marker: MeshInstance3D
const FEED_LANES: Array[float] = [-2.4, 0.0, 2.4]
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
	_setup_practice()
	camera_preview = "--camera-preview" in OS.get_cmdline_user_args()
	if camera_preview:
		enable_camera_preview()
	else:
		var initial_scenario := 1
		var explicit_lab := "--lab" in OS.get_cmdline_user_args()
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--scenario="):
				explicit_lab = true
				initial_scenario = clampi(arg.trim_prefix("--scenario=").to_int() - 1, 0, scenarios.size() - 1)
		if explicit_lab:
			launch_scenario(initial_scenario)
		else:
			set_practice_mode(true)
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
		var actor: Node3D
		if i == 0:
			controlled_player = PLAYER_MOTOR.new()
			actor = controlled_player
		else:
			actor = Node3D.new()
		actor.name = "Player%d" % (i + 1)
		add_child(actor)
		actor.position = positions[i]
		var player := Node3D.new()
		player.name = "Avatar"
		actor.add_child(player)
		if i == 0:
			controlled_player.visual = player
		var shirt := Color("ed8255") if i < 2 else Color("c8e4ef")
		if i == 0:
			_build_articulated_avatar(player, shirt)
			continue
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
			var arm := _mesh("ArmLeft" if side < 0.0 else "ArmRight", limb, shirt, player)
			arm.position = Vector3(side * 0.29, 1.08, -0.03)
			arm.rotation.z = side * 0.25
		var racket := _sphere("Racket", 0.21, Color("d3e457"), player)
		racket.scale = Vector3(0.75, 1.0, 0.12)
		racket.position = Vector3(0.5, 0.85, -0.12)
		if i == 0:
			controlled_player.racket = racket

func _build_articulated_avatar(avatar: Node3D, shirt: Color) -> void:
	var hips := Node3D.new()
	hips.name = "HipsPivot"
	avatar.add_child(hips)
	hips.position.y = 0.65
	for side: float in [-1.0, 1.0]:
		var leg_mesh := CapsuleMesh.new()
		leg_mesh.radius = 0.095
		leg_mesh.height = 0.68
		var leg := _mesh("LegLeft" if side < 0 else "LegRight", leg_mesh, Color("223745"), hips)
		leg.position = Vector3(side * 0.13, -0.23, 0)
		var shoe := BoxMesh.new()
		shoe.size = Vector3(0.18, 0.12, 0.3)
		var foot := _mesh("FootLeft" if side < 0 else "FootRight", shoe, Color("e3e7de"), hips)
		foot.position = Vector3(side * 0.13, -0.58, -0.06)
	var torso := Node3D.new()
	torso.name = "TorsoPivot"
	avatar.add_child(torso)
	torso.position.y = 1.05
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.24
	body_mesh.height = 0.7
	var body := _mesh("Shirt", body_mesh, shirt, torso)
	body.position.y = 0.1
	body.scale.z = 0.68
	var neck_mesh := CapsuleMesh.new()
	neck_mesh.radius = 0.075
	neck_mesh.height = 0.2
	var neck := _mesh("Neck", neck_mesh, Color("d8ad88"), torso)
	neck.position.y = 0.48
	var head := _sphere("Head", 0.18, Color("d8ad88"), torso)
	head.position.y = 0.67
	var nose := _sphere("Nose", 0.055, Color("d8ad88"), torso)
	nose.position = Vector3(0, 0.66, -0.17)
	for side: float in [-1.0, 1.0]:
		var shoulder := _sphere("ShoulderLeft" if side < 0 else "ShoulderRight", 0.105, shirt, torso)
		shoulder.position = Vector3(side * 0.275, 0.25, 0)
		var eye := _sphere("Eye", 0.022, Color("263338"), torso)
		eye.position = Vector3(side * 0.065, 0.72, -0.155)
		for part: String in ["Upper", "Fore"]:
			var mesh := CapsuleMesh.new()
			mesh.radius = 0.065 if part == "Upper" else 0.055
			mesh.height = 0.4
			_mesh(part + ("ArmLeft" if side < 0 else "ArmRight"), mesh, shirt if part == "Upper" else Color("d8ad88"), avatar)
		_sphere("ElbowLeft" if side < 0 else "ElbowRight", 0.065, Color("d8ad88"), avatar)
	var racket := _sphere("Racket", 0.21, Color("d3e457"), avatar)
	racket.scale = Vector3(0.75, 1.0, 0.12)
	racket.position = Vector3(0.5, 0.85, -0.12)
	controlled_player.racket = racket

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
	if practice_mode and aim_marker != null:
		aim_marker.position = shot_controller.target_for_aim(input_adapter.movement()) if simulation.last_hitter != 0 else shot_controller.target
		aim_marker.position.y = 0.025
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
	set_practice_mode(false)
	camera_preview = true
	simulation.active = false
	trail.visible = false
	_update_preview()

func launch_scenario(index: int) -> void:
	if practice_mode:
		set_practice_mode(false)
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
	if event.physical_keycode == KEY_F8:
		if practice_mode:
			set_practice_mode(false)
			launch_scenario(scenario_index)
		else:
			set_practice_mode(true)
		return
	if practice_mode and event.physical_keycode in [KEY_SPACE, KEY_R, KEY_P, KEY_ESCAPE, KEY_L, KEY_N]:
		return # Gameplay adapter consumes action events, including release.
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
	if practice_mode:
		DisplayServer.window_set_title("Pádel · Práctica · WASD/flechas mover · Espacio plano · E globo · R pelota · T zona · P pausa · F8 laboratorio")
	elif camera_preview:
		DisplayServer.window_set_title("Pádel · Prueba visual de cámara · 1/2/3 vistas · G vidrio · Espacio pausa · R reinicio")
	else:
		DisplayServer.window_set_title("Pádel · F%d %s · contacto %s · semilla %d · F1–F7 pruebas · N variar reja · Espacio pausa · R relanzar · L repetir %s" % [scenario_index + 1, scenarios[scenario_index].name, last_contact, launch_seed, "sí" if repeat_launch else "no"])


func _setup_practice() -> void:
	process_physics_priority = 10
	PRACTICE_INPUT.install_actions()
	input_adapter = PRACTICE_INPUT.new()
	input_adapter.name = "PracticeInput"
	add_child(input_adapter)
	controlled_player.input_adapter = input_adapter
	shot_controller = BASIC_SHOT.new()
	shot_controller.name = "BasicShot"
	shot_controller.player = controlled_player
	shot_controller.ball = simulation
	add_child(shot_controller)
	input_adapter.prepare_requested.connect(shot_controller.begin_prepare)
	input_adapter.release_requested.connect(shot_controller.release_shot)
	input_adapter.feed_requested.connect(feed_practice_ball)
	input_adapter.smash_feed_requested.connect(feed_smash_ball)
	input_adapter.next_lane_requested.connect(_next_feed_lane)
	input_adapter.pause_requested.connect(func(): _set_practice_paused(not preview_paused))
	input_adapter.focus_lost.connect(func(): _set_practice_paused(true))
	hud = PRACTICE_HUD.new()
	hud.name = "PracticeHUD"
	hud.controller = shot_controller
	add_child(hud)
	shot_controller.feedback.connect(hud.show_feedback)
	impact_feedback = IMPACT_FEEDBACK.new()
	impact_feedback.name = "ImpactFeedback"
	impact_feedback.player = controlled_player
	impact_feedback.controller = shot_controller
	add_child(impact_feedback)
	hud.impact_feedback = impact_feedback
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.35
	mesh.outer_radius = 0.4
	aim_marker = _mesh("AimMarker", mesh, Color("ddff74"), self)
	aim_marker.position.y = 0.025

func set_practice_mode(enabled: bool) -> void:
	practice_mode = enabled
	preview_paused = false
	camera_preview = false
	repeat_launch = false
	if shot_controller == null:
		return
	impact_feedback.enabled = enabled
	impact_feedback.paused = false
	impact_feedback.reset_presentation()
	shot_controller.enabled = enabled
	shot_controller.paused = false
	shot_controller.reset_cycle()
	input_adapter.enabled = enabled
	input_adapter.paused = false
	controlled_player.enabled = enabled
	controlled_player.selection_ring.visible = enabled
	hud.visible = enabled
	hud.paused = false
	aim_marker.visible = enabled
	if enabled:
		controlled_player.reset_position(Vector3(-2.4, 0, 6.8))
		feed_lane = 0
		simulation.launch(Vector3(FEED_LANES[feed_lane], 1.6, -5.8), Vector3.ZERO, launch_seed)
		simulation.active = false
		trail_points.clear()
		trail.mesh = null
		hud.show_feedback("R para recibir una pelota · el aro marca a tu jugador")
	_update_title()

func feed_practice_ball() -> void:
	_feed_practice(false)

func feed_smash_ball() -> void:
	_feed_practice(true)

func _feed_practice(overhead: bool) -> void:
	if not practice_mode or preview_paused:
		return
	var start := Vector3(FEED_LANES[feed_lane], 1.6, -5.8)
	var speed := Vector3(0, 4.2, 10)
	if overhead:
		speed = shot_controller.solve_lob_velocity(start, Vector3(start.x, simulation.radius, 9.0), 0.55)
	simulation.launch(start, speed, launch_seed)
	shot_controller.reset_cycle()
	impact_feedback.reset_presentation()
	resting_notified = false
	trail_points.clear()
	trail.mesh = null
	hud.show_feedback("Globo en camino · ubicáte debajo y prepará con Espacio" if overhead else "Pelota en camino · llegá, cargá y soltá cerca del 90%")

func _next_feed_lane() -> void:
	if not practice_mode or preview_paused:
		return
	feed_lane = (feed_lane + 1) % FEED_LANES.size()
	feed_practice_ball()

func _set_practice_paused(paused: bool) -> void:
	if not practice_mode or preview_paused == paused:
		return
	if paused:
		resume_ball_active = simulation.active
	preview_paused = paused
	input_adapter.paused = paused
	controlled_player.enabled = not paused
	shot_controller.paused = paused
	shot_controller.reset_cycle()
	simulation.active = false if paused else resume_ball_active
	impact_feedback.paused = paused
	impact_feedback.reset_presentation()
	hud.paused = paused
