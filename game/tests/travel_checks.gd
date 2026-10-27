extends SceneTree
var lab: Node3D
var ball: CharacterBody3D
var failures: Array[String] = []
var results: Array[Dictionary] = []
const DT: float = 1.0 / 120.0

func _initialize() -> void:
	call_deferred("_run")

func _measure(index: int, seed_value: int) -> Dictionary:
	var scenario: Dictionary = lab.scenarios[index]
	ball.launch(scenario.position, scenario.velocity, seed_value)
	var first_wall := false
	var wall_position := Vector3.ZERO
	var wall_normal := Vector3.ZERO
	var previous := ball.position
	var distance_after := 0.0
	var return_distance := 0.0
	var seen := 0
	var stopped_at := -1.0
	for tick in range(1440):
		ball.step(DT)
		for event: Dictionary in ball.contacts.slice(seen):
			if not first_wall and event.surface in ["glass", "fence"]:
				first_wall = true
				wall_position = ball.position
				wall_normal = event.normal
		seen = ball.contacts.size()
		if first_wall:
			distance_after += Vector2(ball.position.x - previous.x, ball.position.z - previous.z).length()
			return_distance = maxf(return_distance, (ball.position - wall_position).dot(wall_normal))
		previous = ball.position
		if ball.grounded and ball.velocity.is_zero_approx():
			stopped_at = ball.elapsed
			break
	var surfaces: Array[String] = []
	for event: Dictionary in ball.contacts:
		surfaces.append(event.surface)
	var result := {"scenario": index + 1, "seed": seed_value, "first_wall_found": first_wall, "return_from_wall_m": return_distance, "horizontal_path_after_wall_m": distance_after, "stopped_at_s": stopped_at, "position": ball.position, "contact_surfaces": surfaces}
	results.append(result)
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
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	var glass := _measure(1, 42)
	var lob := _measure(6, 42)
	var max_fence_return := 0.0
	var max_fence_path := 0.0
	for seed_value in range(20):
		var fence := _measure(2, seed_value)
		max_fence_return = maxf(max_fence_return, fence.return_from_wall_m)
		max_fence_path = maxf(max_fence_path, fence.horizontal_path_after_wall_m)
		if not baseline and (not fence.first_wall_found or fence.return_from_wall_m > 5.0 or fence.stopped_at_s < 0.0):
			failures.append("Ordinary fence launch exceeds calibration range or fails to stop: seed %d" % seed_value)
	if not baseline:
		if not lob.first_wall_found or lob.return_from_wall_m > 4.0 or lob.stopped_at_s < 0.0:
			failures.append("Ordinary lob keeps excessive travel after back glass")
		if glass.return_from_wall_m > 9.0 or glass.stopped_at_s < 0.0:
			failures.append("Low drive reaches too close to net after back glass")
		# Independent constant-deceleration stopping-distance check on the floor.
		ball.launch(Vector3(-2, ball.radius + 0.001, 5), Vector3(3, 0, 0))
		ball.grounded = true
		for tick in range(360):
			ball.step(DT)
		var expected: float = 9.0 / (2.0 * ball.rolling_deceleration)
		if absf((ball.position.x + 2.0) - expected) > 0.03 or not ball.velocity.is_zero_approx():
			failures.append("Rolling distance / finite stop differs from constant-friction estimate")
		var at_rest := ball.position
		var count: int = ball.contacts.size()
		for tick in range(120):
			ball.step(DT)
		if not ball.position.is_equal_approx(at_rest) or ball.contacts.size() != count:
			failures.append("Resting ball moves or emits contacts")
	var report := {"engine": Engine.get_version_info().string, "baseline": baseline, "failures": failures, "ordinary_lob_return_m": lob.return_from_wall_m, "max_ordinary_fence_return_m": max_fence_return, "max_ordinary_fence_path_m": max_fence_path, "cases": results, "note": "Calibration thresholds apply to these ordinary launches, not a universal cap on ball travel."}
	var output := "res://../../../work/travel-baseline.json" if baseline else "res://../docs/previews/travel-checks.json"
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Travel checks: %d failures; lob return %.2f m; fence max return %.2f m, path %.2f m" % [failures.size(), lob.return_from_wall_m, max_fence_return, max_fence_path])
	for message: String in failures:
		push_error(message)
	quit(0 if failures.is_empty() else 1)
