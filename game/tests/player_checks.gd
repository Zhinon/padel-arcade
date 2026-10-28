extends SceneTree
var lab: Node3D
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node
var failures: Array[String] = []
var landings: Array[Dictionary] = []
var overload_cases: Array[Dictionary] = []
const DT: float = 1.0 / 120.0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _event(code: int, pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	return event

func _prepare(duration: float = 0.3) -> void:
	shot.begin_prepare()
	for tick in range(roundi(duration / DT)):
		shot.step(DT)

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab.set_physics_process(false)
	player = lab.controlled_player
	ball = lab.simulation
	shot = lab.shot_controller
	player.set_physics_process(false)
	ball.set_physics_process(false)
	shot.set_physics_process(false)
	_check(lab.practice_mode and not ball.active, "Default practice waits for explicit feed")
	_check(InputMap.event_is_action(_event(KEY_W, true), "padel_forward"), "W maps to move forward")
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_A
	pad.pressed = true
	_check(InputMap.event_is_action(pad, "padel_shot"), "Gamepad A maps to basic shot")
	Input.action_press("padel_right")
	_check(lab.input_adapter.movement().x > 0.9, "Action adapter reads movement")
	Input.action_release("padel_right")
	player.reset_position(Vector3(-2, 0, 3))
	for tick in range(120): player.move_player(Vector2.RIGHT, DT)
	var straight := Vector2(player.position.x + 2, player.position.z - 3).length()
	player.reset_position(Vector3(-2, 0, 3))
	for tick in range(120): player.move_player(Vector2(1, 1), DT)
	var diagonal := Vector2(player.position.x + 2, player.position.z - 3).length()
	_check(absf(straight - diagonal) < 0.03, "Diagonal movement has no speed boost")
	for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for tick in range(360): player.move_player(direction, DT)
		_check(absf(player.position.x) <= 4.601 and player.position.z >= 0.599 and player.position.z <= 9.501, "Player remains in own court")
	player.reset_position(Vector3(-2.4, 0, 6.8))
	for tick in range(30): player.move_player(Vector2.RIGHT, DT)
	var brake_start := player.position
	player.preparing = true
	for tick in range(36): player.move_player(Vector2.LEFT, DT)
	_check(absf(player.position.x - brake_start.x) < 0.25 and absf(player.velocity.x) < 0.01, "Preparation brakes a running player quickly without using aim as movement")
	player.reset_position(Vector3(-2.4, 0, 6.8))
	ball.launch(Vector3(3, 1, 6), Vector3.ZERO)
	shot.reset_cycle()
	var hits_before: int = shot.hits
	_prepare(0.72)
	shot.release_shot(Vector2.RIGHT)
	_check(shot.is_preparing() and not shot.charging and player.preparing, "Release locks charge and preserves planted stance")
	_check(shot.hits == hits_before and absf(shot.shot_charge - 0.9) < 0.006, "Release at 90 percent does not strike remotely")
	shot.step(0.4)
	_check(absf(shot.shot_charge - 0.9) < 0.006, "Locked charge does not grow")
	var planted_start := player.position
	for tick in range(60): player.move_player(Vector2.RIGHT, DT)
	_check(Vector2(player.position.x - planted_start.x, player.position.z - planted_start.z).length() < 0.01, "Aim input cannot run while planted")
	shot.aim = Vector2.LEFT
	ball.position = player.position + Vector3(0, 0.9, -0.65)
	shot.previous_ball_position = ball.position
	var at := ball.position
	var clock: float = ball.elapsed
	var rng_state: int = ball.fence_rng.state
	var perfect_event: Dictionary = {}
	shot.hit.connect(func(event: Dictionary): perfect_event.merge(event, true))
	shot.step(DT)
	_check(shot.hits == hits_before + 1 and ball.last_hitter == 0, "Arrival automatically contacts locked shot")
	_check(perfect_event.get("perfect", false) and shot.target.x < player.position.x, "Prepared 90 percent is perfect and accepts late aim changes")
	var prepared_power: float = shot.effective_power
	_check(ball.position.is_equal_approx(at) and ball.elapsed == clock and ball.fence_rng.state == rng_state, "Strike preserves position/time/RNG")
	for tick in range(60): shot.step(DT)
	_check(ball.strikes.size() == 1 and not player.preparing, "One strike and prompt recovery")
	shot.begin_prepare()
	shot.step(DT)
	_check(ball.strikes.size() == 1 and not shot.is_preparing(), "Same player cannot hit same ball twice")
	shot.reset_cycle()
	ball.launch(player.position + Vector3(0, 0.9, -0.65), Vector3.ZERO)
	shot.begin_prepare()
	shot.aim = Vector2.RIGHT
	shot.step(DT)
	_check(shot.hits == hits_before + 2 and shot.effective_power <= shot.emergency_power and shot.effective_power < prepared_power, "Reachable late contact is weak defense, never rejected for short charge")
	var defensive_power: float = shot.effective_power
	_check(absf(shot.target.x) < 1.5, "Emergency shot has limited directional control")
	shot.reset_cycle()
	ball.launch(Vector3(3, 1, 6), Vector3.ZERO)
	_prepare(0.72)
	shot.release_shot(Vector2.ZERO)
	shot.begin_prepare()
	_check(not player.preparing and not shot.is_preparing(), "New press cancels locked preparation")
	_prepare(0.72)
	shot.release_shot(Vector2.ZERO)
	shot.step(shot.preparation_timeout)
	_check(not shot.is_preparing() and not player.preparing, "Preparation expires without remote strike")
	shot.step(1.0)
	ball.launch(player.position + Vector3(0, 3, -0.65), Vector3.ZERO)
	_prepare(0.72)
	shot.release_shot(Vector2.ZERO)
	shot.step(DT)
	_check(ball.strikes.is_empty(), "High ball cannot be hit by base shot")
	shot.reset_cycle()
	# Arrival while still held must also strike, then require a fresh press.
	ball.launch(player.position + Vector3(0, 0.9, -0.65), Vector3.ZERO)
	shot.begin_prepare()
	shot.step(DT)
	_check(ball.strikes.size() == 1 and not shot.charging, "Held button contacts automatically without release")
	for tick in range(120): shot.step(DT)
	_check(ball.strikes.size() == 1, "Holding through recovery cannot repeat contact")
	# Compare deterministic overload margins and actual first wall contact.
	player.reset_position(Vector3(0, 0, 6.8))
	for direction: Vector2 in [Vector2.UP, Vector2.RIGHT]:
		shot.reset_cycle()
		ball.launch(player.position + Vector3(1.1, 0.3, 0), Vector3.ZERO)
		shot.aim = direction
		shot.preparation_elapsed = 0.02
		shot.shot_charge = 0.9
		var safe: Dictionary = shot.result_for_contact()
		shot.shot_charge = 1.0
		var risky: Dictionary = shot.result_for_contact()
		_check(risky == shot.result_for_contact(), "Overload is deterministic")
		_check(risky.target.z < safe.target.z, "Overload extends intended depth")
		if direction.x > 0: _check(risky.target.x > safe.target.x, "Angled overload extends towards side wall")
		ball.launch(ball.position, shot.solve_velocity(ball.position, risky.target, risky.power))
		var first_surface := ""
		for tick in range(500):
			ball.step(DT)
			if not ball.contacts.is_empty():
				first_surface = ball.contacts[0].surface
				break
		overload_cases.append({"aim": direction, "target": risky.target, "first_surface": first_surface})
		_check(first_surface in ["glass", "fence"], "Poor maximum charge reaches rival enclosure before floor: %s, goal %s, direction %s" % [first_surface, risky.target, direction])
	# Validate real trajectories and first landing against the intended target.
	for z: float in [0.7, 5.0, 9.0]:
		for height: float in [0.3, 0.9, 1.8]:
			for aim_direction: Vector2 in [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				for power: float in [0.2, 1.0]:
					player.reset_position(Vector3(0, 0, z))
					var start := Vector3(0.3, height, z)
					var goal: Vector3 = shot.target_for_aim(aim_direction)
					ball.launch(start, shot.solve_velocity(start, goal, power))
					var floor_event: Dictionary = {}
					var net_hit := false
					for tick in range(400):
						ball.step(DT)
						for event: Dictionary in ball.contacts:
							if event.surface == "net": net_hit = true
							if event.surface == "floor": floor_event = event
						if not floor_event.is_empty(): break
					_check(not net_hit and not floor_event.is_empty(), "Base shot clears net and lands")
					if not floor_event.is_empty():
						var error := Vector2(floor_event.position.x - goal.x, floor_event.position.z - goal.z).length()
						_check(floor_event.position.z < 0.0 and error < 0.4, "Base shot lands near intended opposing target")
						landings.append({"start": start, "power": power, "target": goal, "error_m": error})
	lab.feed_practice_ball()
	lab._set_practice_paused(true)
	_check(not ball.active and not player.enabled, "Pause freezes ball and player")
	lab._set_practice_paused(false)
	_check(ball.active and player.enabled, "Resume restores newly fed ball before first tick")
	# Scripted 30-second integration session; not a human playtest or runtime AI.
	shot.hits = 0
	shot.attempts = 0
	shot.misses = 0
	player.reset_position(Vector3(-2.4, 0, 6.8))
	for tick in range(3600):
		var cycle_tick := tick % 360
		if cycle_tick == 0:
			lab.feed_lane = (tick / 360) % 3
			lab.feed_practice_ball()
		var desired_x: float = lab.FEED_LANES[lab.feed_lane]
		player.move_player(Vector2(clampf((desired_x - player.position.x) * 3, -1, 1), 0), DT)
		ball.step(DT)
		if cycle_tick >= 25 and cycle_tick < 130 and absf(desired_x - player.position.x) < 0.10 and shot.state == shot.State.IDLE: shot.begin_prepare()
		if shot.charging and shot.charge_time >= shot.full_preparation * 0.9:
			shot.release_shot(Vector2.ZERO)
		shot.step(DT)
	_check(shot.hits == 10, "Scripted 30 s practice returns ten feeds across three lanes")
	# Device events also pause on focus loss; mode switches are explicit.
	lab.input_adapter._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_check(lab.preview_paused and not player.enabled, "Focus loss pauses practice")
	lab.input_adapter._unhandled_input(_event(KEY_P, true))
	_check(not lab.preview_paused and player.enabled, "Pause action resumes practice")
	lab._unhandled_key_input(_event(KEY_F8, true))
	_check(not lab.practice_mode and not shot.enabled and not lab.hud.visible, "F8 isolates laboratory mode")
	lab._unhandled_key_input(_event(KEY_F8, true))
	_check(lab.practice_mode and not ball.active and lab.hud.visible, "F8 returns to waiting practice")
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(640, 360)]:
		root.size = resolution
		root.content_scale_size = resolution
		await process_frame
		await process_frame
		var rect: Rect2 = lab.hud.panel.get_global_rect()
		_check(rect.position.x >= 0 and rect.end.x <= resolution.x + 1 and rect.end.y <= resolution.y, "HUD stays inside resized viewport")
	var report := {"engine": Engine.get_version_info().string, "failures": failures, "control_model": "charge, release locks, automatic contact", "prepared_power": prepared_power, "defensive_power": defensive_power, "overload_cases": overload_cases, "straight_distance_m": straight, "diagonal_distance_m": diagonal, "trajectory_cases": landings, "scripted_practice_seconds": 30, "scripted_hits": shot.hits, "note": "Synthetic inputs and scripted driver; no human playability or physical gamepad validation."}
	var file := FileAccess.open("res://../docs/previews/player-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Player checks: %d trajectories, %d scripted returns, %d failures" % [landings.size(), shot.hits, failures.size()])
	for message: String in failures.slice(0, 20): push_error(message)
	quit(0 if failures.is_empty() else 1)
