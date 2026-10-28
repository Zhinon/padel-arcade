extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var lab: Node3D
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node
var pose: Node
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _reset() -> void:
	player.reset_position(Vector3(0, 0, 6.8))
	shot.reset_cycle()
	pose.reset_presentation()
func _capture(label: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	lab._process(0.0)
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/miss-" + label + ".png"))
func _finish_gesture(label: String, before_misses: int, before_sounds: int) -> void:
	var at: Vector3 = player.racket.position
	var max_motion := 0.0
	var speed := ball.velocity
	var clock: float = ball.elapsed
	var position := ball.position
	for tick in range(60):
		shot.step(DT)
		pose.step(DT)
		max_motion = maxf(max_motion, player.racket.position.distance_to(at))
		_check(not pose.flash.visible, label + ": no fake impact flash")
		for mesh: MeshInstance3D in [pose.forearm, pose.off_fore]:
			for i in range(9):
				var point: Vector3 = mesh.position + mesh.basis.y * 0.2 * lerpf(-1, 1, i / 8.0)
				var local: Vector3 = pose.torso.to_local(player.visual.to_global(point))
				var axis := Vector3(0, clampf(local.y, -0.01, 0.21), 0)
				_check(local.distance_to(axis) >= 0.287, label + ": air-swing forearm avoids torso")
		_check(ball.velocity.is_equal_approx(speed) and ball.position.is_equal_approx(position) and ball.elapsed == clock, label + ": air swing never alters ball")
		if tick == 8: await _capture(label + "-forward")
		if tick == 17: await _capture(label + "-follow")
	_check(pose.presented_misses == before_misses + 1, label + ": one air swing only")
	_check(pose.sound_requests == before_sounds, label + ": no impact sound")
	_check(ball.strikes.is_empty() and max_motion > 0.2, label + ": visible swing without strike")
	_check(player.racket.transform.is_equal_approx(pose.racket_rest), label + ": returns to rest")
	cases.append({"case": label, "max_racket_motion_m": max_motion, "miss_count_delta": pose.presented_misses - before_misses, "sound_requests_delta": pose.sound_requests - before_sounds, "strikes": ball.strikes.size()})
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	for connection in lab.input_adapter.focus_lost.get_connections(): lab.input_adapter.focus_lost.disconnect(connection.callable)
	lab._set_practice_paused(false)
	player = lab.controlled_player
	ball = lab.simulation
	shot = lab.shot_controller
	pose = lab.impact_feedback
	for node in [lab, player, ball, shot, pose]: node.set_physics_process(false)
	if "--capture" in OS.get_cmdline_user_args():
		lab.camera.position = Vector3(-0.3, 2.7, 10)
		lab.camera.look_at(Vector3(0, 0.9, 6.8))
		lab.camera.fov = 48
	_reset()
	ball.active = false
	var before_misses: int = pose.presented_misses
	var before_sounds: int = pose.sound_requests
	shot.begin_prepare()
	_check(shot.state == shot.State.MISSED and not player.preparing, "No available ball creates immediate air swing")
	await _finish_gesture("empty", before_misses, before_sounds)
	for side: float in [-1.0, 1.0]:
		_reset()
		ball.launch(Vector3(side * 2.0, 0.9, 6.3), Vector3(0, 0, 12))
		before_misses = pose.presented_misses
		before_sounds = pose.sound_requests
		shot.begin_prepare()
		for tick in range(60):
			ball.step(DT)
			shot.step(DT)
			pose.step(DT)
			if pose.presented_misses > before_misses: break
		_check(ball.elapsed < 0.12 and pose.presented_misses == before_misses + 1, "Miss fires as unreachable ball passes, not after timeout")
		_check(pose.shot_side == ("backhand" if side < 0 else "forehand"), "Air swing selects correct side")
		var before_move := player.position
		player.move_player(Vector2.RIGHT, 0.03)
		_check(player.position.x > before_move.x, "Movement available during missed swing")
		await _finish_gesture("backhand" if side < 0 else "forehand", before_misses, before_sounds)
	_reset()
	ball.launch(Vector3(0, 3, 6.3), Vector3(0, 0, 12))
	before_misses = pose.presented_misses
	before_sounds = pose.sound_requests
	shot.begin_prepare()
	for tick in range(60):
		ball.step(DT)
		shot.step(DT)
		pose.step(DT)
		if pose.presented_misses > before_misses: break
	await _finish_gesture("too-high", before_misses, before_sounds)
	_reset()
	ball.launch(player.position + Vector3(2, 0.9, 0.8), Vector3.ZERO)
	before_misses = pose.presented_misses
	before_sounds = pose.sound_requests
	shot.begin_prepare()
	shot.step(DT)
	_check(pose.presented_misses == before_misses + 1, "Late press after ball passed still swings")
	# Even if a ball re-enters range during recovery, the missed attempt is spent.
	ball.position = player.position + Vector3(0, 0.9, -0.65)
	await _finish_gesture("late", before_misses, before_sounds)
	_reset()
	ball.launch(Vector3(3, 1, -4), Vector3.ZERO)
	before_misses = pose.presented_misses
	shot.begin_prepare()
	shot.release_shot(Vector2.ZERO)
	shot.begin_prepare()
	_check(pose.presented_misses == before_misses and shot.state == shot.State.IDLE, "Cancel remains silent without air swing")
	shot.begin_prepare()
	shot.step(shot.preparation_timeout)
	_check(pose.presented_misses == before_misses + 1, "Expired preparation swings once")
	lab._set_practice_paused(true)
	_check(not pose.miss_animation and not pose.flash.visible, "Pause clears missed swing")
	lab._set_practice_paused(false)
	lab.set_practice_mode(false)
	before_misses = pose.presented_misses
	shot.begin_prepare()
	_check(pose.presented_misses == before_misses, "Laboratory cannot trigger practice swing")
	var report := {"engine": Engine.get_version_info().string, "failures": failures, "cases": cases, "note": "Controller miss events with synthetic inputs; visual captures if requested. Human feel pending."}
	var file := FileAccess.open("res://../docs/previews/missed-swing-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Missed swings: %d gesture cases, %d failures" % [cases.size(), failures.size()])
	for message in failures.slice(0, 8): push_error(message)
	pose.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
