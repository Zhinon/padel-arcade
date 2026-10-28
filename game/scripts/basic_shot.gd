class_name PadelBasicShot
extends Node
signal feedback(message: String)
signal hit(event: Dictionary)
enum State { IDLE, PREPARING, LOCKED, STRIKING, RECOVERING, MISSED }
@export var reach: float = 1.25
@export var ideal_contact_distance: float = 0.65
@export var minimum_height: float = 0.22
@export var maximum_height: float = 2.1
@export var ideal_contact_height: float = 0.9
@export var full_preparation: float = 0.8
@export var perfect_charge: float = 0.9
@export var perfect_tolerance: float = 0.04
@export var preparation_timeout: float = 3.0
@export var recovery_duration: float = 0.18
@export var emergency_recovery: float = 0.28
@export var stabilization_time: float = 0.22
@export var emergency_power: float = 0.32
@export var overload_depth: float = 9.0
@export var overload_width: float = 6.0
@export var overload_net_clearance: float = 0.45
@export var overload_net_risk_strength: float = 1.6
var player: CharacterBody3D
var ball: CharacterBody3D
var enabled: bool = false
var paused: bool = false
var state: State = State.IDLE
var charging: bool = false
var charge_time: float = 0.0
var armed_time: float = 0.0
var recovery: float = 0.0
var shot_charge: float = 0.0
var quality: float = 0.0
var effective_power: float = 0.0
var preparation_elapsed: float = 0.0
var stable_time: float = 0.0
var contact_wait: float = 0.0
var aim := Vector2.ZERO
var target := Vector3(0, 0.105, -5.5)
var previous_ball_position := Vector3.ZERO
var attempts: int = 0
var hits: int = 0
var misses: int = 0

func _ready() -> void:
	process_physics_priority = 20

func is_preparing() -> bool:
	return state in [State.PREPARING, State.LOCKED]

func begin_prepare() -> void:
	if not enabled or paused or recovery > 0.0:
		return
	if state == State.LOCKED:
		cancel_prepare()
		return
	if state != State.IDLE or not ball.active or ball.last_hitter == 0:
		return
	state = State.PREPARING
	attempts += 1
	charging = true
	charge_time = 0.0
	shot_charge = 0.0
	preparation_elapsed = 0.0
	stable_time = 0.0
	contact_wait = 0.0
	aim = Vector2.ZERO
	previous_ball_position = ball.position
	player.preparing = true
	feedback.emit("Preparando · soltá cerca del 90% · direccional apunta")

func release_shot(direction: Vector2) -> void:
	if not enabled or paused or state != State.PREPARING:
		return
	charging = false
	state = State.LOCKED
	aim = direction.limit_length(1.0)
	shot_charge = clampf(charge_time / full_preparation, 0.0, 1.0)
	target = target_for_aim(aim)
	feedback.emit("Carga fijada · apuntá y esperá el contacto")

func cancel_prepare() -> void:
	reset_cycle()
	feedback.emit("Preparación cancelada · podés moverte")

func target_for_aim(direction: Vector2) -> Vector3:
	return Vector3(clampf(player.position.x + direction.x * 4.0, -3.8, 3.8), ball.radius, -5.5 + direction.y * 1.8)

func _physics_process(delta: float) -> void:
	if enabled and not paused:
		if is_preparing() and player.input_adapter != null:
			aim = player.input_adapter.movement()
		step(delta)

func step(delta: float) -> void:
	if not enabled or paused:
		return
	if state in [State.RECOVERING, State.MISSED]:
		recovery = maxf(0.0, recovery - delta)
		if recovery == 0.0:
			state = State.IDLE
	if is_preparing():
		preparation_elapsed += delta
		armed_time = maxf(0.0, preparation_timeout - preparation_elapsed)
		if charging:
			charge_time = minf(full_preparation, charge_time + delta)
			shot_charge = clampf(charge_time / full_preparation, 0.0, 1.0)
		if Vector2(player.velocity.x, player.velocity.z).length() < 0.5:
			stable_time += delta
		else:
			stable_time = 0.0
		target = target_for_aim(aim)
		if contact_reason() == "":
			contact_wait += delta
			var distance := Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length()
			# Wait briefly for a comfortable contact, but retain late defensive reach.
			if distance <= ideal_contact_distance + 0.12 or ball.position.z >= player.position.z - 0.1 or contact_wait >= 0.06:
				_execute_contact()
		elif contact_wait > 0.0:
			_finish_miss("No llegaste al contacto · ajustá tu posición")
		if is_preparing() and (armed_time == 0.0 or not ball.active or ball.position.z > player.position.z + 0.7):
			_finish_miss("Pelota fuera de alcance · preparación terminada")
	previous_ball_position = ball.position

func contact_quality() -> float:
	var distance := Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length()
	var position_quality := clampf(1.0 - absf(distance - ideal_contact_distance) / reach, 0.0, 1.0)
	var height_quality := clampf(1.0 - absf(ball.position.y - ideal_contact_height) / 1.3, 0.0, 1.0)
	var balance := clampf(stable_time / stabilization_time, 0.0, 1.0)
	var preparation := clampf(preparation_elapsed / (full_preparation * 0.65), 0.0, 1.0)
	return clampf(position_quality * 0.3 + height_quality * 0.2 + balance * 0.2 + preparation * 0.3, 0.0, 1.0)

func result_for_contact() -> Dictionary:
	var contact_quality_value := contact_quality()
	var defensive := preparation_elapsed < 0.18 or contact_quality_value < 0.55
	var power := lerpf(0.12, shot_charge, contact_quality_value)
	if defensive:
		power = minf(power, emergency_power)
	var direction_control := lerpf(0.25, 1.0, contact_quality_value)
	if defensive:
		direction_control = minf(direction_control, 0.35)
	var goal := target_for_aim(aim * direction_control)
	if defensive:
		goal.x = lerpf(0.0, goal.x, 0.45)
	var overload := clampf((shot_charge - perfect_charge - perfect_tolerance) / maxf(0.001, 1.0 - perfect_charge - perfect_tolerance), 0.0, 1.0)
	# Deterministic loss of margin, especially when deep/angled and unbalanced.
	var risk := overload * lerpf(1.0, 0.35, contact_quality_value)
	var short_aim := maxf(0.0, aim.y)
	goal.z -= overload_depth * risk * lerpf(0.6, 1.0, maxf(0.0, -aim.y)) * (1.0 - short_aim)
	goal.x += aim.x * overload_width * risk
	return {"quality": contact_quality_value, "power": power, "target": goal, "defensive": defensive, "overload": overload, "net_risk": risk * short_aim}

func _execute_contact() -> void:
	state = State.STRIKING
	var result := result_for_contact()
	quality = result.quality
	effective_power = result.power
	target = result.target
	var outgoing := solve_velocity(ball.position, target, effective_power, result.net_risk)
	ball.strike(outgoing, 0)
	hits += 1
	charging = false
	armed_time = 0.0
	player.preparing = false
	recovery = emergency_recovery if result.defensive else recovery_duration
	state = State.RECOVERING
	var perfect: bool = absf(shot_charge - perfect_charge) <= perfect_tolerance and quality >= 0.85 and not result.defensive
	var message := "Buen contacto · recuperá posición"
	if perfect:
		message = "¡Golpe perfecto!"
	elif result.overload > 0.0:
		message = "Sobrecarga · menos margen sobre la red" if result.net_risk > 0.0 else "Sobrecarga · menos margen al cerramiento"
	elif result.defensive:
		message = "Defensa exigida · poca potencia y dirección"
	feedback.emit(message)
	hit.emit({"position": ball.position, "velocity": outgoing, "target": target, "charge": shot_charge, "quality": quality, "effective_power": effective_power, "defensive": result.defensive, "perfect": perfect, "net_risk": result.net_risk})

func _finish_miss(message: String) -> void:
	misses += 1
	state = State.MISSED
	charging = false
	armed_time = 0.0
	player.preparing = false
	recovery = emergency_recovery
	feedback.emit(message)

func contact_reason() -> String:
	if ball.last_hitter == 0:
		return "Ya golpeaste esta pelota · R para recibir otra"
	if not ball.active:
		return "R para recibir una pelota"
	if ball.position.y < minimum_height:
		return "Pelota demasiado baja"
	if ball.position.y > maximum_height:
		return "Pelota demasiado alta para el golpe base"
	if ball.position.z < 0.25 or ball.position.z > player.position.z + 0.7:
		return "La pelota quedó detrás · ajustá tu posición"
	var center := player.position + Vector3(0, ideal_contact_height, -0.1)
	var closest := Geometry3D.get_closest_point_to_segment(center, previous_ball_position, ball.position)
	if Vector2(closest.x - player.position.x, closest.z - player.position.z).length() > reach or Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length() > reach + 0.15:
		return "Fuera de alcance · acercate a la pelota"
	return ""

func solve_velocity(at: Vector3, goal: Vector3, power: float, net_risk: float = 0.0) -> Vector3:
	var duration := lerpf(1.55, 1.10, clampf(power, 0.0, 1.0))
	var outgoing := Vector3.ZERO
	for iteration in range(10):
		outgoing = _velocity_for_duration(at, goal, duration)
		if _net_height(at, outgoing, duration) >= 1.3:
			break
		duration += 0.10
	if net_risk > 0.0:
		# Apply after the safe-arc assistance, so it cannot erase the risk.
		var normal_height := _net_height(at, outgoing, duration)
		var vertical_response := _net_height(at, outgoing + Vector3.UP, duration) - normal_height
		if is_finite(normal_height) and vertical_response > 0.001:
			var height_loss := maxf(0.0, normal_height - overload_net_clearance) * clampf(net_risk * overload_net_risk_strength, 0.0, 1.0)
			outgoing.y -= height_loss / vertical_response
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
	state = State.IDLE
	charging = false
	charge_time = 0.0
	shot_charge = 0.0
	armed_time = 0.0
	recovery = 0.0
	preparation_elapsed = 0.0
	stable_time = 0.0
	contact_wait = 0.0
	player.preparing = false
	previous_ball_position = ball.position
