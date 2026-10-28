extends SceneTree
## Scripted demonstration driven through Godot input, not runtime AI.
var event_hits: int = 0
func _initialize() -> void:
	call_deferred("_run")

func _key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	var lab = current_scene
	lab._set_practice_paused(false)
	if "--small" in OS.get_cmdline_user_args():
		root.size = Vector2i(640, 360)
		root.content_scale_size = Vector2i(640, 360)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/practice-640x360.png"))
		quit(0 if error == OK else 1)
		return
	var folder := ProjectSettings.globalize_path("res://../../../work/practice-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in range(180):
		if frame in [0, 90]:
			_key(KEY_R if frame == 0 else KEY_T, true)
			_key(KEY_R if frame == 0 else KEY_T, false)
		var desired_x: float = lab.FEED_LANES[lab.feed_lane]
		var error: float = desired_x - lab.controlled_player.position.x
		Input.action_release("padel_left")
		Input.action_release("padel_right")
		if absf(error) > 0.04:
			Input.action_press("padel_right" if error > 0 else "padel_left", minf(1.0, absf(error) * 3))
		if frame in [18, 108]: _key(KEY_SPACE, true)
		if lab.shot_controller.charging and lab.shot_controller.charge_time >= lab.shot_controller.full_preparation * 0.9:
			_key(KEY_SPACE, false)
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var error_code := image.save_png(folder.path_join("frame-%04d.png" % frame))
		if error_code != OK:
			quit(1)
			return
		if frame == 132:
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/practice.png"))
	Input.action_release("padel_left")
	Input.action_release("padel_right")
	print("Input-event demonstration: %d hits, %d attempts, practice mode %s" % [lab.shot_controller.hits, lab.shot_controller.attempts, lab.practice_mode])
	quit(0 if lab.shot_controller.hits == 2 else 1)
