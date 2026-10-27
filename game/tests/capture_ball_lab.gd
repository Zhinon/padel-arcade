extends SceneTree
## Fixed-time render recording for visual inspection. PNG frames stay in work/.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	var lab = current_scene
	lab.repeat_launch = false
	lab.launch_scenario(1)
	var folder := ProjectSettings.globalize_path("res://../../../work/ball-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in range(120):
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var error := image.save_png(folder.path_join("frame-%04d.png" % frame))
		if error != OK:
			push_error("Could not save recording frame")
			quit(1)
			return
		if frame == 45:
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/ball-lab.png"))
	print("Saved 120 rendered frames")
	quit()
