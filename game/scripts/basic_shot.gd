class_name PadelBasicShot
extends Node
signal feedback(message: String)
signal hit(event: Dictionary)
@export var reach: float = 1.25
@export var minimum_height: float = 0.22
@export var maximum_height: float = 2.1
@export var minimum_preparation: float = 0.10
@export var full_preparation: float = 0.8
@export var contact_window: float = 0.20
@export var recovery_duration: float = 0.35
var player: CharacterBody3D
var ball: CharacterBody3D
var enabled: bool = false
var paused: bool = false
var charging: bool = false
var charge_time: float = 0.0
var armed_time: float = 0.0
var recovery: float = 0.0
var shot_charge: float = 0.0
var aim := Vector2.ZERO
var target := Vector3(0, 0.105, -5.5)
var previous_ball_position := Vector3.ZERO
var attempts: int = 0
var hits: int = 0
var misses: int = 0

func _ready() -> void:
	process_physics_priority = 20

func begin_prepare() -> void:
	if not enabled or paused or recovery > 0.0 or armed_time > 0.0 or charging:
		return
	charging = true
	charge_time = 0.0
	player.preparing = true
	feedback.emit("Preparando · soltá Espacio cuando llegue la pelota")

func release_shot(direction: Vector2) -> void:
	if not enabled or paused or not charging:
		return
	attempts += 1
	charging = false
	player.preparing = false
	if charge_time < minimum_preparation:
		misses += 1
		recovery = recovery_duration
		feedback.emit("Preparación muy corta · mantené el botón un instante")
		return
	aim = direction.limit_length(1.0)
	target = target_for_aim(aim)
	shot_charge = clampf(charge_time / full_preparation, 0.0, 1.0)
	armed_time = contact_window
	previous_ball_position = ball.position
	player.swing_time = 0.24

func target_for_aim(direction: Vector2) -> Vector3:
	return Vector3(clampf(player.position.x + direction.x * 4.0, -3.8, 3.8), ball.radius, -5.5 + direction.y * 1.8)

func _physics_process(delta: float) -> void:
	if enabled and not paused:
		step(delta)

func step(delta: float) -> void:
	recovery = maxf(0.0, recovery - delta)
	if charging:
		charge_time = minf(full_preparation, charge_time + delta)
	if armed_time > 0.0:
		if contact_reason() == "":
			var outgoing := solve_velocity(ball.position, target, shot_charge)
			ball.strike(outgoing, 0)
			hits += 1
			armed_time = 0.0
			recovery = recovery_duration
			player.swing_time = 0.24
			feedback.emit("Buen contacto · devolución hacia la zona marcada")
			hit.emit({"position": ball.position, "velocity": outgoing, "target": target, "charge": shot_charge})
		else:
			armed_time = maxf(0.0, armed_time - delta)
			if armed_time == 0.0:
				misses += 1
				recovery = recovery_duration
				feedback.emit(contact_reason())
	previous_ball_position = ball.position

func contact_reason() -> String:
	if ball.last_hitter == 0:
		return "Ya golpeaste esta pelota · R para recibir otra"
	if not ball.active:
		return "R para recibir una pelota"
	if ball.position.y < minimum_height:
		return "Pelota demasiado baja · prepará el golpe antes"
	if ball.position.y > maximum_height:
		return "Pelota demasiado alta para el golpe base"
	if ball.position.z < 0.25 or ball.position.z > player.position.z + 0.7:
		return "La pelota quedó detrás · ajustá tu posición"
	var center := player.position + Vector3(0, 0.9, -0.1)
	var closest := Geometry3D.get_closest_point_to_segment(center, previous_ball_position, ball.position)
	if Vector2(closest.x - player.position.x, closest.z - player.position.z).length() > reach or Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length() > reach + 0.15:
		return "Fuera de alcance · acercate a la pelota"
	return ""

func solve_velocity(at: Vector3, goal: Vector3, power: float) -> Vector3:
	var duration := lerpf(1.55, 1.10, clampf(power, 0.0, 1.0))
	var outgoing := Vector3.ZERO
	for iteration in range(10):
		outgoing = _velocity_for_duration(at, goal, duration)
		if _net_height(at, outgoing, duration) >= 1.3:
			break
		duration += 0.10
	return outgoing

func _velocity_for_duration(at: Vector3, goal: Vector3, duration: float) -> Vector3:
	# Solve the same fixed-step gravity/linear-drag model used by the ball.
	var dt := 1.0 / Engine.physics_ticks_per_second
	var count := maxi(1, ceili(duration / dt))
	var q := exp(-ball.air_drag * dt)
	var sum_q: float
	var gravity_offset: float
	if absf(1.0 - q) < 0.000001:
		sum_q = count
		gravity_offset = ball.gravity_strength * dt * dt * count * (count + 1) * 0.5
	else:
		sum_q = q * (1.0 - pow(q, count)) / (1.0 - q)
		gravity_offset = ball.gravity_strength * dt * dt * q / (1.0 - q) * (count - sum_q)
	return Vector3((goal.x - at.x) / (dt * sum_q), (goal.y - at.y + gravity_offset) / (dt * sum_q), (goal.z - at.z) / (dt * sum_q))

func _net_height(at: Vector3, outgoing: Vector3, duration: float) -> float:
	var dt := 1.0 / Engine.physics_ticks_per_second
	var point := at
	var speed := outgoing
	for tick in range(ceili(duration / dt) + 2):
		var previous := point
		speed.y -= ball.gravity_strength * dt
		speed *= exp(-ball.air_drag * dt)
		point += speed * dt
		if previous.z >= 0.0 and point.z <= 0.0:
			return lerpf(previous.y, point.y, previous.z / (previous.z - point.z))
	return -INF

func reset_cycle() -> void:
	charging = false
	charge_time = 0.0
	armed_time = 0.0
	recovery = 0.0
	player.preparing = false
	previous_ball_position = ball.position
