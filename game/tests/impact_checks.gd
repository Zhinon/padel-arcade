extends SceneTree
## Contact presentation through actual shot events; not a human playtest.
const DT := 1.0 / 120.0
var failures: Array[String] = []
var observations: Array[Dictionary] = []
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	var lab = current_scene
	lab._set_practice_paused(false)
	var player = lab.controlled_player
	var ball = lab.simulation
	var shot = lab.shot_controller
	var presentation = lab.impact_feedback
	for node in [lab, player, ball, shot, presentation]: node.set_physics_process(false)
	_check(presentation.arm != null, "Striking arm is attached to procedural pose")
	for kind: String in ["normal", "perfect", "defense"]:
		player.reset_position(Vector3(-2.4, 0, 6.8))
		presentation.reset_presentation()
		shot.reset_cycle()
		ball.launch(Vector3(3, 1.0, 6.8), Vector3.ZERO)
		var before_preparation: int = presentation.sound_requests
		shot.begin_prepare()
		var ticks := 86 if kind == "perfect" else (42 if kind == "normal" else 1)
		for tick in range(ticks):
			shot.step(DT)
			presentation.step(DT)
		_check(presentation.sound_requests == before_preparation, "Preparation without contact is silent")
		shot.release_shot(Vector2.ZERO)
		if "--capture" in OS.get_cmdline_user_args() and kind == "perfect":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/impact-preparation.png"))
		ball.position = player.position + Vector3(0.0, 0.9, -0.65)
		shot.previous_ball_position = ball.position
		var hits_before: int = presentation.presented_hits
		var sound_before: int = presentation.sound_requests
		shot.step(DT)
		_check(presentation.presented_hits == hits_before + 1 and ball.strikes.size() == 1, "One presentation per real hit")
		_check(presentation.last_kind == kind, "Shot classified as " + kind)
		var contact_error: float = player.racket.global_position.distance_to(ball.global_position)
		_check(contact_error < 0.0001, "Racket coincides with contact in same callback")
		_check(presentation.flash.position.distance_to(ball.position) < 0.0001, "Flash at real contact")
		_check(presentation.sound_requests == sound_before + 1 and presentation.audio.stream == presentation.SOUNDS[kind], "Matching audio requested at contact")
		_check(presentation.audio.stream.get_length() > 0.05, "Audio stream imported with real samples")
		var outgoing: Vector3 = ball.velocity
		var player_at: Vector3 = player.position
		if "--capture" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/impact-%s.png" % kind))
		for tick in range(14): presentation.step(DT)
		_check(ball.velocity.is_equal_approx(outgoing) and player.position.is_equal_approx(player_at), "Presentation never moves ball or player body")
		var moving_start: Vector3 = player.position
		player.move_player(Vector2.RIGHT, 0.05)
		_check(player.position.x > moving_start.x, "Follow-through does not block movement")
		for tick in range(60): presentation.step(DT)
		_check(not presentation.flash.visible and player.racket.transform.is_equal_approx(presentation.racket_rest), "Feedback returns to neutral")
		observations.append({"kind": kind, "contact_error_m": contact_error, "sound": presentation.audio.stream.resource_path, "sound_length_s": presentation.audio.stream.get_length()})
	# Muting uses the same hit route; geometry and physics remain active.
	presentation.set_muted(true)
	var sounds_before: int = presentation.sound_requests
	ball.launch(player.position + Vector3(0, 0.9, -0.65), Vector3.ZERO)
	shot.reset_cycle()
	shot.begin_prepare()
	shot.step(DT)
	_check(presentation.sound_requests == sounds_before and presentation.flash.visible, "Muted hit retains visual feedback without audio request")
	lab._set_practice_paused(true)
	_check(not presentation.flash.visible and not presentation.audio.playing, "Pause clears effect and sound")
	lab._set_practice_paused(false)
	_check(presentation.muted, "Mute persists through pause")
	var mute_key := InputEventKey.new()
	mute_key.physical_keycode = KEY_M
	mute_key.pressed = true
	presentation._unhandled_input(mute_key)
	_check(not presentation.muted, "M action unmutes presentation")
	presentation._unhandled_input(mute_key)
	_check(presentation.muted, "M action mutes presentation")
	lab.set_practice_mode(false)
	var before_lab: int = presentation.presented_hits
	presentation.present_hit({"perfect": false, "defensive": false, "position": ball.position})
	_check(presentation.presented_hits == before_lab and not presentation.flash.visible, "Laboratory isolates practice feedback")
	var report := {"engine": Engine.get_version_info().string, "failures": failures, "observations": observations, "note": "Actual shot events and render captures if requested; audio dispatch verified, human listening pending."}
	var file := FileAccess.open("res://../docs/previews/impact-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Impact checks: %d kinds, %d failures" % [observations.size(), failures.size()])
	for message in failures: push_error(message)
	presentation.reset_presentation()
	# Let the audio mixer release stopped voices before the fast test exits.
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
