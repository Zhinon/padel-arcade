extends SceneTree
## Run separate engine processes with --fixed-fps 30 / 60 / 120.
var lab: Node3D
var ball: CharacterBody3D
var render_frames: int = 0
var render_fps: int = 0

func _initialize() -> void:
	process_frame.connect(func(): render_frames += 1)
	call_deferred("_run")

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--fps="):
			render_fps = int(arg.trim_prefix("--fps="))
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab.set_physics_process(false)
	ball = lab.simulation
	ball.set_physics_process(false)
	await physics_frame
	ball.launch(Vector3(0, 1.4, -2), Vector3(11, 2, 0), 42)
	ball.stepped.connect(_sample)
	ball.set_physics_process(true)

func _sample() -> void:
	if ball.elapsed < 2.0 - 0.000001:
		return
	ball.active = false
	var events: Array[Dictionary] = []
	for event: Dictionary in ball.contacts:
		events.append({"time": event.time, "surface": event.surface, "position": [event.position.x, event.position.y, event.position.z]})
	var report := {"scenario": "fence_seed_42", "render_schedule_fps": render_fps, "observed_render_frames": render_frames, "physics_ticks_per_second": Engine.physics_ticks_per_second, "elapsed": ball.elapsed, "position": [ball.position.x, ball.position.y, ball.position.z], "velocity": [ball.velocity.x, ball.velocity.y, ball.velocity.z], "events": events}
	var file := FileAccess.open("res://../docs/previews/ball-fps-%d.json" % render_fps, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	quit()
