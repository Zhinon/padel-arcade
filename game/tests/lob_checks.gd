extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var events: Array[Dictionary] = []
var lab: Node3D
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node
var adapter: Node

func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _key(code: int, pressed: bool) -> InputEventKey:
	var key := InputEventKey.new()
	key.physical_keycode = code
	key.pressed = pressed
	return key
func _press(code: int, pressed: bool) -> void:
	adapter._unhandled_input(_key(code, pressed))
func _contact(z: float, height: float, direction: Vector2, charge: float, early: bool = true) -> Dictionary:
	player.reset_position(Vector3(0, 0, z))
	shot.reset_cycle()
	lab.impact_feedback.reset_presentation()
	ball.launch(Vector3(4, 1, -3), Vector3.ZERO)
	_press(KEY_K, true)
	for tick in range(roundi(charge * shot.full_preparation / DT)): shot.step(DT)
	_press(KEY_K, false)
	if early:
		for tick in range(80): shot.step(DT)
	shot.aim = direction
	ball.position = player.position + Vector3(0, height, -0.65)
	shot.previous_ball_position = ball.position
	shot.step(DT)
	_check(ball.strikes.size() == 1 and events.back().shot_type == "lob", "K selects real automatic lob")
	return events.back().duplicate(true)
func _flight(event: Dictionary) -> Dictionary:
	var apex: float = ball.position.y
	var visible_apex := true
	var time := 0.0
	for tick in range(600):
		ball.step(DT)
		time += DT
		if ball.position.y > apex:
			apex = ball.position.y
			visible_apex = lab.camera.is_position_in_frustum(ball.position)
		if not ball.contacts.is_empty():
			var first: Dictionary = ball.contacts[0]
			return {"charge": event.charge, "quality": event.quality, "defensive": event.defensive, "target": event.target, "surface": first.surface, "landing": first.position, "apex": apex, "visible_apex": visible_apex, "time_s": time, "error_m": Vector2(first.position.x - event.target.x, first.position.z - event.target.z).length()}
	return {"surface": "none"}
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab._set_practice_paused(false)
	player = lab.controlled_player
	ball = lab.simulation
	shot = lab.shot_controller
	adapter = lab.input_adapter
	for node in [lab, player, ball, shot, lab.impact_feedback]: node.set_physics_process(false)
	shot.hit.connect(func(event: Dictionary): events.append(event))
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_B
	pad.pressed = true
	_check(InputMap.event_is_action(pad, "padel_lob") and InputMap.event_is_action(_key(KEY_K, true), "padel_lob"), "K and gamepad B map to lob")
	_check(InputMap.event_is_action(_key(KEY_J, true), "padel_shot"), "J maps to flat shot")
	_check(not InputMap.event_is_action(_key(KEY_SPACE, true), "padel_shot") and not InputMap.event_is_action(_key(KEY_E, true), "padel_lob"), "Old Space/E bindings no longer trigger strokes")
	# Switching resets charge, not positional preparation; stale release is ignored.
	ball.launch(Vector3(4, 1, -3), Vector3.ZERO)
	_press(KEY_J, true)
	shot.step(0.3)
	var preparation: float = shot.preparation_elapsed
	_press(KEY_K, true)
	_check(shot.shot_kind == shot.ShotType.LOB and shot.shot_charge == 0 and shot.preparation_elapsed == preparation, "Other button switches intent without carrying stored charge")
	_press(KEY_J, false)
	_check(shot.charging, "Release of previous button cannot lock new stroke")
	shot.step(0.2)
	_press(KEY_K, false)
	_check(shot.state == shot.State.LOCKED, "Release of selected button locks its charge")
	_press(KEY_K, true)
	_check(not player.preparing and shot.shot_kind == shot.ShotType.FLAT, "Same button cancels locked lob and clears kind")
	_press(KEY_K, true)
	shot.step(0.2)
	_press(KEY_K, false)
	_press(KEY_J, true)
	_check(shot.shot_kind == shot.ShotType.FLAT and shot.charging and shot.shot_charge == 0, "Flat button switches a locked lob into fresh flat charge")
	_press(KEY_K, false)
	_check(shot.charging, "Old lob release cannot lock flat shot")
	shot.reset_cycle()
	_press(KEY_K, true)
	shot.step(0.72)
	ball.position = player.position + Vector3(0, 0.9, -0.65)
	shot.previous_ball_position = ball.position
	shot.step(DT)
	_check(events.back().shot_type == "lob" and ball.strikes.size() == 1 and not shot.charging, "Held lob strikes automatically without release")
	for tick in range(120): shot.step(DT)
	_check(ball.strikes.size() == 1, "Held lob never repeats contact")
	for z: float in [2.0, 5.0, 9.0]:
		for height: float in [0.3, 0.9, 1.8]:
			for direction: Vector2 in [Vector2(-0.6, -0.8), Vector2.ZERO, Vector2(0.6, 0.8)]:
				for charge: float in [0.3, 0.9]:
					var event := _contact(z, height, direction, charge)
					var result := _flight(event)
					cases.append(result)
					_check(result.surface == "floor" and result.landing.z < 0 and result.error_m < 0.25, "Prepared lob clears net and lands before enclosure: %s" % result)
					_check(result.apex >= 3.6 and result.apex <= 5.5 + 0.1 and result.visible_apex, "Lob visibly rises and remains in current camera")
	var low_event := _contact(6.8, 0.9, Vector2.ZERO, 0.25)
	var low := _flight(low_event)
	var high_event := _contact(6.8, 0.9, Vector2.ZERO, 0.9)
	var high := _flight(high_event)
	_check(high.apex > low.apex + 1.0 and high.landing.z < low.landing.z - 1.5, "Higher charge gives higher and deeper lob")
	var late := _contact(6.8, 0.9, Vector2.RIGHT, 0.0, false)
	var late_flight := _flight(late)
	_check(late.defensive and late.effective_power <= shot.emergency_power and absf(late.target.x) < 1.0 and late_flight.landing.z > -5, "Late lob remains weak, short and less directed")
	var overload := _flight(_contact(6.8, 0.3, Vector2.UP, 1.0, false))
	_check(overload.surface in ["glass", "fence"], "Poor overload can hit enclosure directly")
	var feeds: Array[Dictionary] = []
	for lane in range(3):
		player.reset_position(Vector3(lab.FEED_LANES[lane], 0, 6.8))
		lab.feed_lane = lane
		lab.feed_practice_ball()
		var before: int = events.size()
		for tick in range(300):
			ball.step(DT)
			if tick == 30: _press(KEY_K, true)
			if shot.charging and shot.shot_charge >= 0.9: _press(KEY_K, false)
			shot.step(DT)
			if events.size() > before: break
		_check(events.size() == before + 1 and events.back().shot_type == "lob", "Real feed uses E for lob in lane %d" % lane)
		if events.size() > before:
			ball.contacts.clear()
			var feed := _flight(events.back())
			feeds.append(feed)
			_check(feed.surface == "floor" and feed.landing.z < -6 and feed.visible_apex, "Real feed lob clears net, rises visibly and lands deep")
	# Isolate pause, focus loss, lab and R for the newly added button.
	shot.reset_cycle()
	ball.launch(Vector3(4, 1, -3), Vector3.ZERO)
	adapter._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_check(lab.preview_paused and not player.enabled, "Focus loss pauses the new stroke")
	_press(KEY_K, true)
	_check(not shot.is_preparing(), "Pause blocks lob input")
	lab._set_practice_paused(false)
	_press(KEY_K, true)
	lab.feed_practice_ball()
	_check(shot.shot_kind == shot.ShotType.FLAT and not shot.is_preparing(), "R clears lob preparation")
	lab.set_practice_mode(false)
	_press(KEY_K, true)
	_check(not shot.is_preparing(), "Lab blocks lob input")
	lab.set_practice_mode(true)
	if "--capture" in OS.get_cmdline_user_args():
		for connection in adapter.focus_lost.get_connections(): adapter.focus_lost.disconnect(connection.callable)
		shot.hits = 0
		_contact(6.8, 0.9, Vector2.ZERO, 0.9)
		lab.aim_marker.position = Vector3(shot.target.x, 0.025, shot.target.z)
		var folder := ProjectSettings.globalize_path("res://../../../work/lob-frames")
		DirAccess.make_dir_recursive_absolute(folder)
		for frame in range(90):
			for tick in range(4):
				ball.step(DT)
				shot.step(DT)
				lab.impact_feedback.step(DT)
			await process_frame
			RenderingServer.force_draw()
			root.get_texture().get_image().save_png(folder.path_join("frame-%04d.png" % frame))
			if frame == 28: root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/lob.png"))
	if "--small" in OS.get_cmdline_user_args():
		for connection in adapter.focus_lost.get_connections(): adapter.focus_lost.disconnect(connection.callable)
		root.size = Vector2i(640, 360)
		root.content_scale_size = root.size
		lab.feed_practice_ball()
		_press(KEY_K, true)
		shot.step(0.35)
		_press(KEY_K, false)
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		var rect: Rect2 = lab.hud.panel.get_global_rect()
		_check(rect.end.x <= 640 and rect.end.y <= 360 and lab.hud.title.text.contains("K: globo") and lab.hud.status.text.contains("Globo fijado"), "Compact HUD identifies both buttons and locked lob within viewport")
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/lob-controls-640x360.png"))
	var file := FileAccess.open("res://../docs/previews/lob-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine": Engine.get_version_info().string, "dt": DT, "failures": failures, "cases": cases, "feeds": feeds, "low_charge": low, "high_charge": high, "late": late_flight, "overload": overload, "note": "Synthetic keyboard events and real swept trajectories, three actual feeds. No human or physical gamepad test."}, "\t"))
	file.close()
	print("Lob checks: %d trajectories, %d failures" % [cases.size(), failures.size()])
	for message in failures.slice(0, 10): push_error(message)
	lab.impact_feedback.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
