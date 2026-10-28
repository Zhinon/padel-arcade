extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var ball: CharacterBody3D
var baseline: bool = false
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _simulate(label: String, start: Vector3, speed: Vector3) -> void:
	ball.launch(start, speed)
	var floor_time := -1.0
	for tick in range(600):
		ball.step(DT)
		for event: Dictionary in ball.contacts:
			if event.surface == "floor" and floor_time < 0.0: floor_time = event.time
		if floor_time >= 0.0: break
	var net_seen := false
	for event: Dictionary in ball.contacts:
		net_seen = net_seen or event.surface == "net"
		_check(event.outgoing.length() <= event.incoming.length() + 0.001, label + ": no added collision energy")
	_check(ball.position.is_finite() and ball.velocity.is_finite(), label + ": finite state")
	if not baseline:
		_check(floor_time >= 0.0, label + ": eventually falls to floor")
		_check(ball.impact_limit_count == 0, label + ": no exhausted collision budget")
	cases.append({"case": label, "start": start, "initial_velocity": speed, "net_seen": net_seen, "floor_time_s": floor_time, "end_position": ball.position, "end_velocity": ball.velocity, "contacts": ball.contacts.size(), "impact_limits": ball.impact_limit_count})
func _run() -> void:
	baseline = "--baseline" in OS.get_cmdline_user_args()
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	var lab = current_scene
	lab.set_practice_mode(false)
	lab.set_physics_process(false)
	ball = lab.simulation
	ball.set_physics_process(false)
	for x: float in [-4.25, -2.25, 0.25, 2.25, 4.25]:
		var top := 0.88 + 0.04 * absf(x) / 5.0
		for z: float in [-0.006, 0.0, 0.006]:
			_simulate("tape_%s_%s" % [x, z], Vector3(x, top + ball.radius + 0.15, z), Vector3(0, -0.3, 0))
			_check(cases.back().net_seen, "Vertical tape test must touch net")
	# Repeat actual 100% short-shot trajectories, including several contact heights.
	var player = lab.controlled_player
	var shot = lab.shot_controller
	for x: float in [-2.4, 0.0, 2.4]:
		player.reset_position(Vector3(x, 0, 6.8))
		for height: float in [0.3, 0.9, 1.8]:
			for distance: float in [0.65, 1.1]:
				ball.launch(Vector3(x, height, player.position.z - distance), Vector3.ZERO)
				shot.aim = Vector2.DOWN
				shot.preparation_elapsed = 0.8
				shot.stable_time = 0.8
				shot.shot_charge = 1.0
				var result: Dictionary = shot.result_for_contact()
				var start := ball.position
				_simulate("short_100_%s_%s_%s" % [x, height, distance], start, shot.solve_velocity(start, result.target, result.power, result.net_risk))
	# A ball already travelling across the tape must retain that direction.
	for direction: float in [-1.0, 1.0]:
		_simulate("skim_%s" % direction, Vector3(0.25, 0.882 + ball.radius + 0.001, 0), Vector3(0, -0.5, direction * 2.0))
		_check(not ball.contacts.is_empty() and ball.contacts[0].surface == "net", "Skim contacts tape")
		if not ball.contacts.is_empty():
			_check(ball.contacts[0].outgoing.z * direction > 0.0 and ball.position.z * direction > 0.0, "Tape skim preserves cross-net momentum")
	var stuck := 0
	for result: Dictionary in cases:
		if result.floor_time_s < 0.0: stuck += 1
	var report := {"engine": Engine.get_version_info().string, "baseline": baseline, "failures": failures, "no_floor_after_5s": stuck, "cases": cases}
	var name := "net-tape-before.json" if baseline else "net-tape-checks.json"
	var file := FileAccess.open("res://../docs/previews/" + name, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Net tape: %d cases, %d without floor after 5 s, %d failures" % [cases.size(), stuck, failures.size()])
	for message in failures.slice(0, 8): push_error(message)
	quit(0 if failures.is_empty() else 1)
