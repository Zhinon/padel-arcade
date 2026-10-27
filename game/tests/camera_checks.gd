extends SceneTree
## Geometry checks are separate from rendered captures and user review.

var failures: Array[String] = []
var results: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var lab = current_scene
	lab.preview_paused = true
	var capture := "--capture" in OS.get_cmdline_user_args()
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(640, 360)]:
		root.size = resolution
		root.content_scale_size = resolution
		await process_frame
		for preset in range(3):
			lab.set_camera_preset(preset)
			lab.elapsed = 1.5
			lab._update_preview()
			await process_frame
			var rect: Rect2 = root.get_visible_rect()
			var camera: Camera3D = lab.camera
			var outside := 0
			for x: float in [-5.1, 5.1]:
				for z: float in [-10.1, 10.1]:
					for y: float in [0.0, 4.0]:
						var point := Vector3(x, y, z)
						if camera.is_position_behind(point) or not rect.has_point(camera.unproject_position(point)):
							outside += 1
			var smallest_ball := INF
			for sample in range(101):
				var point: Vector3 = lab.preview_point(sample / 100.0)
				var screen := camera.unproject_position(point)
				if camera.is_position_behind(point) or not rect.grow(-6.0).has_point(screen):
					outside += 1
				var diameter := camera.unproject_position(point + Vector3(0.105, 0, 0)).distance_to(camera.unproject_position(point - Vector3(0.105, 0, 0)))
				smallest_ball = minf(smallest_ball, diameter)
			if outside > 0:
				failures.append("Preset %d / %s: %d points outside frame" % [preset + 1, str(resolution), outside])
			results.append({"preset": preset + 1, "resolution": str(resolution), "viewport": str(rect.size), "outside_points": outside, "min_ball_diameter_px": snappedf(smallest_ball, 0.01)})
			if capture:
				await RenderingServer.frame_post_draw
				var path := ProjectSettings.globalize_path("res://../docs/previews/camera-%d-%dx%d.png" % [preset + 1, resolution.x, resolution.y])
				var error := root.get_texture().get_image().save_png(path)
				if error != OK:
					failures.append("Capture failed: %s" % error)
	var court = lab.court
	var piece: MeshInstance3D = court.near_enclosure[0]
	var ghost_alpha: float = piece.material_override.albedo_color.a
	court.set_near_wall_ghost(false)
	var solid_alpha: float = piece.material_override.albedo_color.a
	if not ghost_alpha < solid_alpha:
		failures.append("Near enclosure does not fade")
	court.set_near_wall_ghost(true)
	var pause_event := InputEventKey.new()
	pause_event.physical_keycode = KEY_SPACE
	pause_event.pressed = true
	lab._unhandled_key_input(pause_event)
	if lab.preview_paused:
		failures.append("Space did not toggle preview pause")
	lab.preview_paused = true
	var reset_event := InputEventKey.new()
	reset_event.physical_keycode = KEY_R
	reset_event.pressed = true
	lab._unhandled_key_input(reset_event)
	if lab.elapsed != 0.0 or not lab.ball.position.is_equal_approx(lab.preview_point(0.0)):
		failures.append("Reset did not restore preview origin")
	var report := {"engine": Engine.get_version_info().string, "ball_visual_radius_m": 0.105, "note": "Geometry checks only; ball is enlarged for readability, not a regulation model. No occlusion or human readability assertion.", "checks": results, "failures": failures}
	var file := FileAccess.open("res://../docs/previews/camera-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
