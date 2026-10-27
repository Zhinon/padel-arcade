extends SceneTree
var ball: CharacterBody3D
var lab: Node3D
var failures: Array[String] = []
var variants: Array[Dictionary] = []
const DT: float = 1.0 / 120.0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _launch(at: Vector3, speed: Vector3, seed_value: int, duration: float) -> Dictionary:
	ball.launch(at, speed, seed_value)
	for tick in range(roundi(duration / DT)):
		ball.step(DT)
	for event: Dictionary in ball.contacts:
		_check(event.outgoing.length() <= event.incoming.length() + 0.001, "Surface must not create energy")
	_check(ball.impact_limit_count == 0, "No impact budget exhaustion")
	return {"position": ball.position, "velocity": ball.velocity, "contacts": ball.contacts.duplicate(true)}

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
	var glass := _launch(Vector3(0, 2.5, -8), Vector3(0, 0, -15), 42, 0.25)
	_check(not glass.contacts.is_empty(), "Glass impact exists")
	if not glass.contacts.is_empty():
		var event: Dictionary = glass.contacts[0]
		var normal_ratio: float = absf(event.outgoing.z / event.incoming.z)
		_check(normal_ratio >= 0.60 and normal_ratio <= 0.75, "Glass normal response is damped for prototype")
		_check(absf(event.outgoing.y) < absf(event.incoming.y), "Glass also damps tangential motion")
	var lob: Dictionary = lab.scenarios[6]
	ball.launch(lob.position, lob.velocity)
	var passed_glass := false
	var second_floor := false
	var max_z_before_second_bounce := -INF
	var seen_contacts := 0
	for tick in range(600):
		ball.step(DT)
		if passed_glass and not second_floor:
			max_z_before_second_bounce = maxf(max_z_before_second_bounce, ball.position.z)
		for event: Dictionary in ball.contacts.slice(seen_contacts):
			if event.surface == "glass":
				passed_glass = true
			elif passed_glass and event.surface == "floor":
				second_floor = true
		seen_contacts = ball.contacts.size()
	var lob_events: Array = ball.contacts.duplicate(true)
	_check(lob_events.size() >= 3, "Lob has floor/glass/floor sequence")
	if lob_events.size() >= 3:
		_check(lob_events[0].surface == "floor" and lob_events[1].surface == "glass" and lob_events[2].surface == "floor", "Ordinary lob hits floor before glass")
	_check(second_floor and max_z_before_second_bounce < 0.0, "Ordinary lob does not cross net after back glass before second bounce")
	var min_heading := INF
	var max_heading := -INF
	for seed_value in range(20):
		var result := _launch(Vector3(0, 1.4, -2), Vector3(11, 2, 0), seed_value, 0.6)
		_check(not result.contacts.is_empty(), "Fence contact exists")
		if result.contacts.is_empty():
			continue
		var event: Dictionary = result.contacts[0]
		_check(event.surface == "fence", "Fence classified")
		_check(event.outgoing.dot(event.normal) > 0.0, "Fence deflection stays inside court")
		var heading := rad_to_deg(atan2(event.outgoing.z, -event.outgoing.x))
		min_heading = minf(min_heading, heading)
		max_heading = maxf(max_heading, heading)
		variants.append({"seed": seed_value, "heading_degrees": heading, "deflection_degrees": event.fence_deflection_degrees, "outgoing": event.outgoing})
	_check(min_heading < -5.0 and max_heading > 5.0, "Fence produces meaningful deviations in both directions")
	var a := _launch(Vector3(0, 1.4, -2), Vector3(11, 2, 0), 42, 0.6)
	var b := _launch(Vector3(0, 1.4, -2), Vector3(11, 2, 0), 42, 0.6)
	_check(a.position.distance_to(b.position) < 0.00001 and a.velocity.distance_to(b.velocity) < 0.00001, "Same seed replays fence impact")
	var different := _launch(Vector3(0, 1.4, -2), Vector3(11, 2, 0), 43, 0.6)
	_check(a.position.distance_to(different.position) > 0.01, "Different seed produces different fence result")
	var next_seed := InputEventKey.new()
	next_seed.physical_keycode = KEY_N
	next_seed.pressed = true
	var previous_seed: int = lab.launch_seed
	lab._unhandled_key_input(next_seed)
	_check(lab.launch_seed == previous_seed + 1 and ball.elapsed == 0.0, "N increments seed and relaunches")
	var report := {"engine": Engine.get_version_info().string, "failures": failures, "glass": glass, "lob_contacts": lob_events, "lob_max_z_before_second_bounce": max_z_before_second_bounce, "fence_heading_range_degrees": [min_heading, max_heading], "fence_variants": variants, "note": "Design calibration, not measured material values; spin is not implemented."}
	var file := FileAccess.open("res://../docs/previews/surface-calibration.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Surface calibration: %d failures; fence heading %.1f to %.1f degrees" % [failures.size(), min_heading, max_heading])
	for message: String in failures:
		push_error(message)
	quit(0 if failures.is_empty() else 1)
