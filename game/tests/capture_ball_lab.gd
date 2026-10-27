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
	lab.set_practice_mode(false)
	lab.repeat_launch = false
	var fence_demo := "--fence-demo" in OS.get_cmdline_user_args()
	var lob_demo := "--lob-demo" in OS.get_cmdline_user_args()
	var prefix := "lob-lab" if lob_demo else ("fence-lab" if fence_demo else "ball-lab")
	var frame_count := 240 if lob_demo or fence_demo else 120
	lab.launch_scenario(6 if lob_demo else (2 if fence_demo else 1))
	var folder := ProjectSettings.globalize_path("res://../../../work/" + prefix + "-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in range(frame_count):
		if fence_demo and frame == 120:
			lab.launch_seed = 43
			lab.launch_scenario(2)
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var error := image.save_png(folder.path_join("frame-%04d.png" % frame))
		if error != OK:
			push_error("Could not save recording frame")
			quit(1)
			return
		if frame == (105 if lob_demo else 45):
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/" + prefix + ".png"))
	print("Saved %d rendered frames" % frame_count)
	quit()
