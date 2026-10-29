class_name PadelTrainingRival
extends Node
## Training opponent: bounded reaction/prediction and the same motor/shot controller.
const SHOT = preload("res://scripts/basic_shot.gd")
const FEEDBACK = preload("res://scripts/impact_feedback.gd")
@export var reaction_time: float = 0.24
@export var replan_interval: float = 0.12
@export var prediction_horizon: float = 2.8
@export var desired_charge: float = 0.70
@export var restart_delay: float = 1.8
var lab: Node3D
var player: CharacterBody3D
var human: CharacterBody3D
var ball: CharacterBody3D
var controller: Node
var presentation: Node3D
var enabled := false
var paused := false
var waiting_restart := false
var restart_remaining := 0.0
var rally_hits := 0
var best_rally := 0
var rounds := 0
var reaction_remaining := 0.0
var replan_remaining := 0.0
var move_direction := Vector2.ZERO
var shot_aim := Vector2.ZERO
var destination := Vector3.ZERO
var arrival_time := INF
var plan_valid := false
var own_bounces := 0
var expected_half := 1.0
var returns := 0

func _ready() -> void:
	process_physics_priority = -20
	player.input_adapter = self
	controller = SHOT.new()
	controller.name = "RivalShot"
	controller.player = player
	controller.ball = ball
	controller.hitter_id = 1
	controller.court_sign = -1.0
	add_child(controller)
	presentation = FEEDBACK.new()
	presentation.name = "RivalPresentation"
	presentation.player = player
	presentation.controller = controller
	add_child(presentation)
	controller.hit.connect(func(_event: Dictionary): returns += 1)
	ball.struck.connect(_on_struck)
	ball.contacted.connect(_on_contact)
	ball.launched.connect(_on_launched)
	destination = Vector3(-2.4,0,-6.8)

func movement() -> Vector2:
	return shot_aim if player.preparing else move_direction

func set_enabled(value: bool) -> void:
	enabled = value and lab.practice_mode
	paused = lab.preview_paused
	player.enabled = enabled and not paused
	controller.enabled = enabled
	controller.paused = paused
	controller.reset_cycle()
	presentation.enabled = enabled
	presentation.paused = paused
	presentation.reset_presentation()
	lab.get_node("Player2").visible = not enabled
	lab.get_node("Player4").visible = not enabled
	waiting_restart = false
	move_direction = Vector2.ZERO
	if enabled:
		restart_rally()
	else:
		lab.shot_controller.enabled = lab.practice_mode
		lab.shot_controller.reset_cycle()
		player.reset_position(Vector3(-2.2,0,-6.3))
		lab.hud.show_feedback("Práctica individual · I para activar rival · R/H para recibir")

	lab._update_title()

func set_paused(value: bool) -> void:
	paused = value
	player.enabled = enabled and not paused
	controller.paused = paused
	controller.reset_cycle()
	presentation.paused = paused
	presentation.reset_presentation()
	move_direction = Vector2.ZERO
	reaction_remaining = reaction_time
	replan_remaining = 0.0

func restart_rally() -> void:
	if not enabled or paused: return
	# Explicit new-rally placement only, never used to reach an incoming ball.
	human.reset_position(Vector3(-2.4,0,6.8))
	player.reset_position(Vector3(-2.4,0,-6.8))
	lab.feed_lane = 0
	lab._feed_practice(false)
	lab.hud.show_feedback("Peloteo · devolvé con J/K · el rival responde · I: práctica individual")

func _on_launched() -> void:
	if not enabled: return
	waiting_restart = false
	restart_remaining = 0.0
	rally_hits = 0
	own_bounces = 0
	expected_half = 1.0
	plan_valid = false
	arrival_time = INF
	reaction_remaining = reaction_time
	replan_remaining = 0.0
	move_direction = Vector2.ZERO
	controller.enabled = true
	controller.reset_cycle()
	lab.shot_controller.enabled = true
	presentation.reset_presentation()
	rounds += 1

func _on_struck(event: Dictionary) -> void:
	if not enabled or waiting_restart: return
	rally_hits += 1
	best_rally = maxi(best_rally,rally_hits)
	own_bounces = 0
	expected_half = -1.0 if event.hitter == 0 else 1.0
	reaction_remaining = reaction_time
	replan_remaining = 0.0
	plan_valid = false
	move_direction = Vector2.ZERO

func _on_contact(event: Dictionary) -> void:
	if not enabled or paused or waiting_restart: return
	var half: float = signf(event.position.z)
	if event.surface == "floor":
		if half != expected_half:
			finish_rally("No pasó a la otra mitad")
		else:
			own_bounces += 1
			if own_bounces >= 2: finish_rally("Segundo pique")
	elif event.surface in ["glass","fence"] and half == expected_half and own_bounces == 0:
		finish_rally("Cerramiento directo antes del pique")

func finish_rally(reason: String) -> void:
	if waiting_restart: return
	waiting_restart = true
	restart_remaining = restart_delay
	controller.reset_cycle()
	controller.enabled = false
	lab.shot_controller.reset_cycle()
	lab.shot_controller.enabled = false
	lab.input_adapter.reset_buttons()
	move_direction = Vector2.ZERO
	lab.hud.show_feedback("%s · %d golpes · nueva pelota en un momento · R reinicia" % [reason,rally_hits])

func _physics_process(delta: float) -> void: step(delta)

func step(delta: float) -> void:
	if not enabled or paused: return
	if waiting_restart:
		restart_remaining = maxf(0.0,restart_remaining-delta)
		if restart_remaining == 0.0: restart_rally()
		return
	if ball.grounded and ball.velocity.length() < 0.1:
		finish_rally("Pelota detenida")
		return
	if absf(ball.position.x)>5.3 or absf(ball.position.z)>10.3 or ball.position.y < -1.0 or ball.elapsed > 18.0 and rally_hits == 0:
		finish_rally("Pelota fuera de la zona de práctica")
		return
	move_direction = Vector2.ZERO
	if ball.last_hitter != 0:
		# Recover at normal speed; no charge while freely moving.
		_move_towards(Vector3(clampf(human.position.x,-2.8,2.8),0,-6.2))
		return
	reaction_remaining = maxf(0.0,reaction_remaining-delta)
	if reaction_remaining > 0.0: return
	if controller.is_preparing():
		if controller.charging and controller.shot_charge >= desired_charge:
			controller.release_shot(shot_aim)
		return
	if controller.recovery > 0: return
	replan_remaining -= delta
	if replan_remaining <= 0.0:
		var plan := predict_intercept()
		plan_valid = not plan.is_empty()
		if plan_valid:
			destination = plan.position
			arrival_time = plan.time
		else: arrival_time = INF
		replan_remaining = replan_interval
	if not plan_valid: return
	var distance := Vector2(destination.x-player.position.x,destination.z-player.position.z).length()
	if distance < 0.18 and arrival_time <= 1.15:
		# Training placement follows the user's lane, without matching them perfectly.
		var desired_x: float = -clampf(human.position.x,-3.5,3.5)
		shot_aim = Vector2(clampf((desired_x + player.position.x)/4.0,-0.8,0.8),-0.1)
		controller.begin_prepare(controller.ShotType.LOB if human.position.z < 3.2 else controller.ShotType.FLAT)
	else:
		_move_towards(destination)

func _move_towards(at: Vector3) -> void:
	var offset := Vector2(at.x-player.position.x,at.z-player.position.z)
	if offset.length()>0.08: move_direction = offset.normalized() * minf(1.0,offset.length()/0.35)

func predict_intercept() -> Dictionary:
	# Read-only approximate forecast. Rebounds use shared material parameters;
	# fence deflection is deliberately not predicted from the simulation RNG.
	var at: Vector3 = controller.court_vector(ball.position)
	var speed: Vector3 = controller.court_vector(ball.velocity)
	var dt := 1.0 / 60.0
	var bounces := own_bounces if expected_half * controller.court_sign > 0 else 0
	for tick in range(ceili(prediction_horizon/dt)):
		speed.y -= ball.gravity_strength*dt
		speed *= exp(-ball.air_drag*dt)
		at += speed*dt
		if at.y < ball.radius:
			at.y = ball.radius
			var approach := absf(speed.y)
			var tangent: Vector3 = ball.floor_tangent(Vector3(speed.x,0,speed.z),approach)
			speed = tangent*ball.floor_retention + Vector3.UP*approach*ball.floor_bounce
			if at.z > 0: bounces += 1
			if bounces >= 2: break
		if absf(at.x)>4.88:
			at.x = clampf(at.x,-4.88,4.88)
			speed.x *= -ball.glass_bounce
			speed.z *= ball.glass_retention
		if at.z>9.88:
			at.z = 9.88
			speed.z *= -ball.glass_bounce
			speed.x *= ball.glass_retention
		if absf(at.x)>5.1 or at.z>10.1: break
		var time := (tick+1)*dt
		if at.z < 0.6 or at.z > 8.9 or at.y < 0.55 or at.y > 1.8: continue
		var stand := Vector3(clampf(at.x,-4.4,4.4),0,clampf(at.z+0.6,0.7,9.4))
		var world_stand: Vector3 = controller.court_vector(stand)
		var distance := Vector2(world_stand.x-player.position.x,world_stand.z-player.position.z).length()
		if distance/player.speed+0.22 <= time and (speed.z>0 or bounces>0):
			return {"position":world_stand,"time":time,"bounces":bounces}
	return {}
