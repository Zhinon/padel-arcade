extends SceneTree

var failures: Array[String] = []
var cases: Array[Dictionary] = []
var lab: Node3D
var ball: CharacterBody3D
const DT: float = 1.0 / 120.0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _simulate(label: String, at: Vector3, speed: Vector3, duration: float, contained: bool = true) -> Dictionary:
	ball.launch(at, speed)
	var minimum_y := INF
	var max_x := 0.0
	var max_z := 0.0
	for tick in range(roundi(duration / DT)):
		ball.step(DT)
		minimum_y = minf(minimum_y, ball.position.y)
		max_x = maxf(max_x, absf(ball.position.x))
		max_z = maxf(max_z, absf(ball.position.z))
		_check(ball.position.is_finite() and ball.velocity.is_finite(), label + ": finite state")
		if contained:
			_check(absf(ball.position.x) <= 5.002 and absf(ball.position.z) <= 10.002, label + ": no wall tunneling")
			_check(ball.position.y >= ball.radius - 0.002, label + ": no floor tunneling")
	var previous_time := -1.0
	for event: Dictionary in ball.contacts:
		_check(event.time >= previous_time, label + ": chronological contacts")
		_check(event.outgoing.length() <= event.incoming.length() + 0.001, label + ": passive impact must not add energy")
		previous_time = event.time
	_check(ball.impact_limit_count == 0, label + ": impact iteration budget")
	var result := {"name": label, "position": ball.position, "velocity": ball.velocity, "contacts": ball.contacts.duplicate(true), "minimum_y": minimum_y, "max_x": max_x, "max_z": max_z, "impact_limit_count": ball.impact_limit_count}
	cases.append(result)
	return result

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab.set_process(false)
	lab.set_physics_process(false)
	ball = lab.simulation
	ball.set_physics_process(false)
	var falling := _simulate("vertical_drop", Vector3(0, 3, 5), Vector3.ZERO, 1.0)
	_check(falling.contacts.size() == 1, "drop: exactly one bounce in first second")
	if not falling.contacts.is_empty():
		var hit: Dictionary = falling.contacts[0]
		_check(hit.surface == "floor", "drop: first surface floor")
		var ideal_time := sqrt(2.0 * (3.0 - ball.radius) / ball.gravity_strength)
		_check(absf(hit.time - ideal_time) < 0.025, "drop: impact time near independent ballistic estimate")
		_check(absf(hit.outgoing.y / -hit.incoming.y - ball.floor_bounce) < 0.001, "drop: restitution")
	var glass := _simulate("back_glass", Vector3(0, 2.5, -8), Vector3(0, 0, -15), 0.25)
	_check(not glass.contacts.is_empty() and glass.contacts[0].surface == "glass", "glass: classified contact")
	_check(glass.velocity.z > 0.0, "glass: direction reversed")
	var fence := _simulate("side_fence", Vector3(0, 2, -2), Vector3(40, 0, 0), 0.2)
	_check(not fence.contacts.is_empty() and fence.contacts[0].surface == "fence", "fence: classified contact")
	_check(fence.velocity.x < 0.0, "fence: direction reversed")
	var net := _simulate("net", Vector3(0, 0.55, 4), Vector3(0, 0, -14), 0.4)
	_check(not net.contacts.is_empty() and net.contacts[0].surface == "net", "net: blocks low crossing")
	_check(net.position.z > 0.0, "net: ball remains on launch side")
	var corner := _simulate("glass_corner", Vector3(3.5, 1.8, 8.5), Vector3(10, 1, 10), 0.25)
	_check(corner.velocity.x < 0.0 and corner.velocity.z < 0.0, "corner: both directions reversed")
	_simulate("fast_shot_60mps", Vector3(0, 1.5, -4), Vector3(60, 0, 0), 1.0)
	_simulate("fence_glass_seam", Vector3(0, 3, -8), Vector3(0, 0, -60), 0.25)
	var high := _simulate("upper_corner_fence", Vector3(3.5, 3.6, 9), Vector3(30, 0, 0), 0.15)
	_check(not high.contacts.is_empty() and high.contacts[0].surface == "fence", "corner: mesh above glass is solid")
	var escaped := _simulate("above_fence_escape", Vector3(0, 4.5, -2), Vector3(40, 4, 0), 0.2, false)
	_check(escaped.position.x > 5.2 and escaped.contacts.is_empty(), "high ball: no invisible wall above enclosure")
	_simulate("settle_on_floor", Vector3(0, 1, 5), Vector3.ZERO, 15.0)
	_check(ball.grounded and ball.velocity.length() < 0.03, "settling: rest reached")
	var count: int = ball.contacts.size()
	for tick in range(240):
		ball.step(DT)
	_check(ball.contacts.size() == count, "settling: no repeated contact spam")
	lab.court.set_near_wall_ghost(true)
	var ghost := _simulate("ghost_glass", Vector3(0, 2.5, 8), Vector3(0, 0, 15), 0.25)
	lab.court.set_near_wall_ghost(false)
	var opaque := _simulate("opaque_glass", Vector3(0, 2.5, 8), Vector3(0, 0, 15), 0.25)
	_check(ghost.position.distance_to(opaque.position) < 0.00001, "visual fade: physical surface unchanged")
	# Exact repetition inside this engine/build; no cross-platform guarantee.
	var repeated := _simulate("repeat_glass", Vector3(0, 2.5, 8), Vector3(0, 0, 15), 0.25)
	_check(opaque.position.distance_to(repeated.position) < 0.00001, "reset: same launch repeats within tolerance")
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	space.pressed = true
	lab._unhandled_key_input(space)
	var paused_position := ball.position
	var paused_time: float = ball.elapsed
	ball._physics_process(DT)
	_check(ball.position == paused_position and ball.elapsed == paused_time, "pause: physics remains frozen")
	lab._unhandled_key_input(space)
	ball._physics_process(DT)
	_check(ball.elapsed > paused_time, "resume: physics advances")
	var reset := InputEventKey.new()
	reset.physical_keycode = KEY_R
	reset.pressed = true
	lab._unhandled_key_input(reset)
	_check(ball.elapsed == 0.0 and ball.contacts.is_empty(), "reset: clears elapsed time and contacts")
	_check(ball.position.is_equal_approx(lab.scenarios[lab.scenario_index].position), "reset: restores launch state")
	var scenario_key := InputEventKey.new()
	scenario_key.physical_keycode = KEY_F4
	scenario_key.pressed = true
	lab._unhandled_key_input(scenario_key)
	_check(lab.scenario_index == 3 and ball.velocity.z == -14.0, "F4: selects net scenario")
	var report := {"engine": Engine.get_version_info().string, "step_seconds": DT, "prototype_radius_m": ball.radius, "failures": failures, "cases": cases}
	var file := FileAccess.open("res://../docs/previews/ball-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Ball checks: %d scenarios, %d failures" % [cases.size(), failures.size()])
	for message: String in failures.slice(0, 20):
		push_error(message)
	quit(0 if failures.is_empty() else 1)
