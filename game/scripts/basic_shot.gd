class_name PadelBasicShot
extends Node
signal feedback(message: String)
signal hit(event: Dictionary)
signal missed(event: Dictionary)
enum State { IDLE, PREPARING, LOCKED, STRIKING, RECOVERING, MISSED }
enum ShotType { FLAT, LOB, SPECIAL }
@export var special_chord_window: float = 0.10
@export var special_net_distance: float = 2.8
@export var special_quality: float = 0.85
@export var special_direction_threshold: float = 0.55
var shot_kind: ShotType = ShotType.FLAT
@export var lob_min_apex: float = 3.0
@export var lob_max_apex: float = 5.5
@export var lob_min_depth: float = 4.0
@export var lob_max_depth: float = 8.0
@export var reach: float = 1.25
@export var ideal_contact_distance: float = 0.65
@export var minimum_height: float = 0.22
@export var maximum_height: float = 2.1
@export var ideal_contact_height: float = 0.9
@export var smash_min_height: float = 2.15
@export var smash_max_height: float = 2.65
@export var smash_ideal_height: float = 2.4
@export var smash_reach: float = 0.75
@export var smash_low_speed: float = 13.0
@export var smash_high_speed: float = 26.0
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
@export var touch_charge_limit: float = 0.40
@export var touch_charge_fade: float = 0.65
@export var touch_depth: float = 1.6
@export var touch_net_height: float = 1.16
@export var touch_minimum_power: float = 0.18
@export var touch_net_penalty: float = 0.9
@export var touch_horizontal_speed: float = 8.0
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

func begin_prepare(kind: int = ShotType.FLAT, combine: bool = false) -> void:
	if not enabled or paused or recovery > 0.0:
		return
	if combine and is_preparing() and charging and charge_time <= special_chord_window:
		shot_kind = ShotType.SPECIAL
		feedback.emit("Especial · lateral: x3 · adelante: x4 · fijá ~90%")
		return
	if state == State.LOCKED and shot_kind == ShotType.SPECIAL:
		cancel_prepare()
		return
	if is_preparing() and kind != shot_kind:
		# Switching buttons changes intent, retaining stance but not stored charge.
		shot_kind = kind as ShotType
		charge_time = 0.0
		shot_charge = 0.0
		charging = true
		state = State.PREPARING
		target = target_for_aim(aim)
		feedback.emit("Globo · nueva carga" if shot_kind == ShotType.LOB else "Plano · nueva carga")
		return
	if state == State.LOCKED:
		cancel_prepare()
		return
	if state != State.IDLE:
		return
	shot_kind = kind as ShotType
	if not ball.active or ball.last_hitter == 0:
		attempts += 1
		_finish_miss("Abanicazo · R para recibir otra pelota")
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
	feedback.emit("Preparando globo · carga elige altura y profundidad" if shot_kind == ShotType.LOB else "Preparando plano · poca carga + abajo: chiquita · 90%: potencia")

func release_shot(direction: Vector2, kind: int = -1) -> void:
	if not enabled or paused or state != State.PREPARING or (kind >= 0 and kind != shot_kind and shot_kind != ShotType.SPECIAL):
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
	if shot_kind == ShotType.LOB:
		return _lob_target(direction, shot_charge)
	var depth := -5.5 + direction.y * 1.8
	if not is_smash_preparation():
		depth = lerpf(depth, -touch_depth, touch_weight(direction, shot_charge))
	return Vector3(clampf(player.position.x + direction.x * 4.0, -3.8, 3.8), ball.radius, depth)

func is_smash_preparation() -> bool:
	return shot_kind in [ShotType.FLAT,ShotType.SPECIAL] and ball.active and ball.last_hitter != 0 and ball.position.y >= smash_min_height and ball.position.z >= 0.25 and ball.position.z <= player.position.z + 0.1

func special_direction() -> String:
	if absf(aim.x) >= special_direction_threshold: return "x3"
	if aim.y <= -special_direction_threshold: return "x4"
	return ""

func is_smash_context() -> bool:
	return is_smash_preparation() and ball.position.y <= smash_max_height and ball.velocity.y <= 0.5

func touch_weight(direction: Vector2, charge: float) -> float:
	# Blend continuously into a short shot; charge is intent, not contact quality.
	return smoothstep(0.2, 0.8, direction.y) * (1.0 - smoothstep(touch_charge_limit, touch_charge_fade, charge))

func _lob_target(direction: Vector2, power: float) -> Vector3:
	return Vector3(clampf(player.position.x + direction.x * 4.0, -3.8, 3.8), ball.radius, clampf(-lerpf(lob_min_depth, lob_max_depth, power) + direction.y * 1.8, -9.0, -3.0))

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
			var ready := distance <= ideal_contact_distance + 0.12 or ball.position.z >= player.position.z - 0.1 or contact_wait >= 0.06
			if is_smash_context():
				ready = ball.position.y <= smash_ideal_height + 0.08 or ball.position.z >= player.position.z - 0.12 or contact_wait >= 0.09
			if ready:
				_execute_contact()
		elif contact_wait > 0.0:
			_finish_miss("No llegaste al contacto · ajustá tu posición")
		elif ball.velocity.z > 0.0 and previous_ball_position.z < player.position.z - 0.1 and ball.position.z >= player.position.z - 0.1:
			_finish_miss("Abanicazo · la pelota quedó fuera de alcance")
		if is_preparing() and (armed_time == 0.0 or not ball.active or ball.position.z > player.position.z + 0.7):
			_finish_miss("Pelota fuera de alcance · preparación terminada")
	previous_ball_position = ball.position

func contact_quality() -> float:
	var distance := Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length()
	var position_quality := clampf(1.0 - absf(distance - ideal_contact_distance) / reach, 0.0, 1.0)
	var height_quality := clampf(1.0 - absf(ball.position.y - ideal_contact_height) / 1.3, 0.0, 1.0)
	if is_smash_context():
		position_quality = clampf(1.0 - absf(distance - 0.4) / smash_reach, 0.0, 1.0)
		height_quality = clampf(1.0 - absf(ball.position.y - smash_ideal_height) / 0.65, 0.0, 1.0)
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
	if shot_kind == ShotType.LOB:
		goal = _lob_target(aim * direction_control, power)
	if defensive:
		goal.x = lerpf(0.0, goal.x, 0.45)
	var overload := clampf((shot_charge - perfect_charge - perfect_tolerance) / maxf(0.001, 1.0 - perfect_charge - perfect_tolerance), 0.0, 1.0)
	# Deterministic loss of margin, especially when deep/angled and unbalanced.
	var risk := overload * lerpf(1.0, 0.35, contact_quality_value)
	var short_aim := maxf(0.0, aim.y)
	goal.z -= overload_depth * risk * lerpf(0.6, 1.0, maxf(0.0, -aim.y)) * (1.0 if shot_kind == ShotType.LOB else (1.0 - short_aim))
	goal.x += aim.x * overload_width * risk
	return {"quality": contact_quality_value, "power": power, "target": goal, "defensive": defensive, "overload": overload, "net_risk": 0.0 if shot_kind == ShotType.LOB else risk * short_aim, "touch": 0.0 if shot_kind == ShotType.LOB or is_smash_context() else touch_weight(aim, shot_charge), "smash": is_smash_context()}

func _execute_contact() -> void:
	state = State.STRIKING
	var result := result_for_contact()
	quality = result.quality
	effective_power = result.power
	target = result.target
	var special: Dictionary = {}
	if shot_kind == ShotType.SPECIAL and result.smash and player.position.z <= special_net_distance and quality >= special_quality and absf(shot_charge-perfect_charge) <= perfect_tolerance and special_direction() != "":
		special = PadelSpecialSmash.plan(ball,ball.position,special_direction(),signf(aim.x))
	var outgoing: Vector3
	if special.has("velocity"):
		outgoing = special.velocity
		target = special.landing
	elif shot_kind == ShotType.LOB:
		outgoing = solve_lob_velocity(ball.position, target, effective_power)
	elif result.smash and not result.defensive:
		outgoing = solve_smash_velocity(ball.position, target, effective_power, result.net_risk)
	else:
		outgoing = solve_velocity(ball.position, target, effective_power, result.net_risk, result.touch, quality)
	ball.strike(outgoing, 0)
	hits += 1
	charging = false
	armed_time = 0.0
	player.preparing = false
	recovery = emergency_recovery if result.defensive else recovery_duration
	state = State.RECOVERING
	var touch_shot: bool = result.touch >= 0.9 and not result.defensive
	var ideal_charge: bool = shot_charge >= 0.12 and shot_charge <= touch_charge_limit if touch_shot else absf(shot_charge - perfect_charge) <= perfect_tolerance
	var perfect: bool = ideal_charge and quality >= 0.85 and not result.defensive
	var message := "Buen contacto · recuperá posición"
	if special.has("velocity"):
		message = "¡Intento de smash %s!" % special.kind
	elif shot_kind == ShotType.SPECIAL:
		message = "Especial no disponible · remate normal" if result.smash else "Especial no disponible · devolución normal"
	elif shot_kind == ShotType.LOB:
		message = "Globo exigido · corto y con menos dirección" if result.defensive else ("¡Globo bien preparado!" if perfect else "Globo · recuperá posición")
		if result.overload > 0.0: message = "Globo sobrecargado · riesgo de cerramiento directo"
	elif result.smash:
		message = "Remate exigido · devolución suave" if result.defensive else ("¡Smash bien preparado!" if perfect else "Smash · recuperá posición")
		if result.overload > 0.0: message = "Smash sobrecargado · menos margen"
	elif touch_shot:
		message = "¡Chiquita bien colocada!" if perfect else "Chiquita · suave a los pies"
	elif perfect:
		message = "¡Golpe perfecto!"
	elif result.overload > 0.0:
		message = "Sobrecarga · menos margen sobre la red" if result.net_risk > 0.0 else "Sobrecarga · menos margen al cerramiento"
	elif result.defensive:
		message = "Defensa exigida · poca potencia y dirección"
	feedback.emit(message)
	hit.emit({"position": ball.position, "velocity": outgoing, "target": target, "charge": shot_charge, "quality": quality, "effective_power": effective_power, "defensive": result.defensive, "perfect": perfect, "net_risk": result.net_risk, "touch": result.touch, "special":special,"shot_type": special.kind if special.has("velocity") else ("smash" if result.smash else ("lob" if shot_kind == ShotType.LOB else ("chiquita" if touch_shot else ("defense" if result.defensive else "flat"))))})

func _finish_miss(message: String) -> void:
	misses += 1
	state = State.MISSED
	charging = false
	armed_time = 0.0
	player.preparing = false
	recovery = emergency_recovery
	feedback.emit(message)
	missed.emit({"ball_position": ball.position, "ball_available": ball.active and ball.last_hitter != 0, "charge": shot_charge, "reason": message})

func contact_reason() -> String:
	if ball.last_hitter == 0:
		return "Ya golpeaste esta pelota · R para recibir otra"
	if not ball.active:
		return "R para recibir una pelota"
	if ball.position.y < minimum_height:
		return "Pelota demasiado baja"
	var overhead := is_smash_context()
	if ball.position.y > (smash_max_height if overhead else maximum_height):
		return "Pelota demasiado alta para el golpe base"
	if ball.position.z < 0.25 or ball.position.z > player.position.z + 0.7:
		return "La pelota quedó detrás · ajustá tu posición"
	var contact_reach := smash_reach if overhead else reach
	var center := player.position + Vector3(0, smash_ideal_height if overhead else ideal_contact_height, -0.1)
	var closest := Geometry3D.get_closest_point_to_segment(center, previous_ball_position, ball.position)
	if Vector2(closest.x - player.position.x, closest.z - player.position.z).length() > contact_reach or Vector2(ball.position.x - player.position.x, ball.position.z - player.position.z).length() > contact_reach + 0.15:
		return "Fuera de alcance · acercate a la pelota"
	return ""

func solve_velocity(at: Vector3, goal: Vector3, power: float, net_risk: float = 0.0, touch: float = 0.0, contact: float = 1.0) -> Vector3:
	var duration := lerpf(1.55, 1.10, clampf(power, 0.0, 1.0))
	var outgoing := Vector3.ZERO
	for iteration in range(10):
		outgoing = _velocity_for_duration(at, goal, duration)
		if _net_height(at, outgoing, duration) >= 1.3:
			break
		duration += 0.10
	if touch > 0.0:
		# Find a lower arc for the short destination using the actual fixed-step model.
		# Poor contact with insufficient power loses net margin instead of being rescued.
		var deficit := clampf((touch_minimum_power - power) / touch_minimum_power, 0.0, 1.0)
		var low := maxf(0.15, Vector2(goal.x - at.x, goal.z - at.z).length() / touch_horizontal_speed)
		# Account for drag and tick rounding when bounding initial horizontal speed.
		for tick in range(12):
			var minimum_velocity := _velocity_for_duration(at, goal, low)
			if Vector2(minimum_velocity.x, minimum_velocity.z).length() <= touch_horizontal_speed:
				break
			low += 1.0 / Engine.physics_ticks_per_second
		var high := maxf(3.0, low)
		for iteration in range(22):
			var middle := (low + high) * 0.5
			var candidate := _velocity_for_duration(at, goal, middle)
			if _net_height(at, candidate, middle) < touch_net_height:
				low = middle
			else:
				high = middle
		var soft_velocity := _velocity_for_duration(at, goal, high)
		var normal_height := _net_height(at, soft_velocity, high)
		var response := _net_height(at, soft_velocity + Vector3.UP, high) - normal_height
		var weakness := deficit * (1.0 - contact)
		if response > 0.001 and weakness > 0.0001:
			var desired_height := touch_net_height - weakness * touch_net_penalty
			soft_velocity.y -= maxf(0.0, normal_height - desired_height) / response
		outgoing = outgoing.lerp(soft_velocity, touch)
	return _apply_net_risk(at, outgoing, duration, net_risk)

func _apply_net_risk(at: Vector3, outgoing: Vector3, duration: float, net_risk: float) -> Vector3:
	if net_risk > 0.0:
		# Apply after the safe-arc assistance, so it cannot erase the risk.
		var normal_height := _net_height(at, outgoing, duration)
		var vertical_response := _net_height(at, outgoing + Vector3.UP, duration) - normal_height
		if is_finite(normal_height) and vertical_response > 0.001:
			var height_loss := maxf(0.0, normal_height - overload_net_clearance) * clampf(net_risk * overload_net_risk_strength, 0.0, 1.0)
			outgoing.y -= height_loss / vertical_response
	return outgoing

func solve_smash_velocity(at: Vector3, goal: Vector3, power: float, net_risk: float) -> Vector3:
	var distance := Vector2(goal.x - at.x, goal.z - at.z).length()
	var duration := maxf(0.18, distance / lerpf(smash_low_speed, smash_high_speed, clampf(power, 0.0, 1.0)))
	return _apply_net_risk(at, _velocity_for_duration(at, goal, duration), duration, net_risk)

func solve_lob_velocity(at: Vector3, goal: Vector3, power: float) -> Vector3:
	var apex := maxf(at.y + 0.15, lerpf(lob_min_apex, lob_max_apex, clampf(power, 0.0, 1.0)))
	var low := 0.3
	var high := 3.5
	for iteration in range(22):
		var duration := (low + high) * 0.5
		var candidate := _velocity_for_duration(at, goal, duration)
		var point := at
		var speed := candidate
		var highest := at.y
		var dt := 1.0 / Engine.physics_ticks_per_second
		for tick in range(ceili(duration / dt)):
			speed.y -= ball.gravity_strength * dt
			speed *= exp(-ball.air_drag * dt)
			point += speed * dt
			highest = maxf(highest, point.y)
		if highest < apex:
			low = duration
		else:
			high = duration
	return _velocity_for_duration(at, goal, high)

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
	shot_kind = ShotType.FLAT
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
