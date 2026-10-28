extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var lab: Node3D
var pose: Node
var player: CharacterBody3D
var minimum_clearance: float = INF
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _arm_clearance(label: String) -> void:
	for mesh: MeshInstance3D in [pose.forearm, pose.off_fore, pose.arm, pose.off_upper]:
		var half_axis: Vector3 = mesh.basis.y * 0.2
		for i in range(13):
			var point: Vector3 = mesh.position + half_axis * lerpf(-1, 1, i / 12.0)
			var local: Vector3 = pose.torso.to_local(player.visual.to_global(point))
			var axis := Vector3(0, clampf(local.y, -0.01, 0.21), 0)
			var is_forearm: bool = mesh in [pose.forearm, pose.off_fore]
			var clearance := local.distance_to(axis) - (0.24 + (0.055 if is_forearm else 0.065))
			if is_forearm: minimum_clearance = minf(minimum_clearance, clearance)
			_check(clearance >= -0.008, label + ": arm stays outside torso except shoulder attachment")
	var racket_local: Vector3 = pose.torso.to_local(player.racket.global_position)
	var racket_axis := Vector3(0, clampf(racket_local.y, -0.01, 0.21), 0)
	_check(racket_local.distance_to(racket_axis) >= 0.445, label + ": racket stays outside torso")
func _capture(label: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	lab._process(0.0)
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/pose-" + label + ".png"))
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	for connection in lab.input_adapter.focus_lost.get_connections():
		lab.input_adapter.focus_lost.disconnect(connection.callable)
	lab._set_practice_paused(false)
	player = lab.controlled_player
	var ball = lab.simulation
	var shot = lab.shot_controller
	pose = lab.impact_feedback
	for node in [lab, player, ball, shot, pose]: node.set_physics_process(false)
	# Test close-up camera only; the runtime camera presets are untouched.
	if "--capture" in OS.get_cmdline_user_args():
		lab.camera.position = Vector3(-0.3, 2.7, 10.0)
		lab.camera.look_at(Vector3(0, 0.9, 6.7))
		lab.camera.fov = 48
	for side: float in [-1.0, 0.0, 1.0]:
		for height: float in [0.3, 0.9, 1.8]:
			for charge_ticks: int in [1, 86]:
				player.reset_position(Vector3(0, 0, 6.8))
				pose.reset_presentation()
				pose.set_muted(true)
				shot.reset_cycle()
				ball.launch(Vector3(side * 0.8, height, 3), Vector3.ZERO)
				shot.begin_prepare()
				for tick in range(charge_ticks):
					shot.step(DT)
					pose.step(DT)
					_arm_clearance("preparation")
				var expected := "backhand" if side < 0 else "forehand"
				_check(pose.shot_side == expected, "Select " + expected)
				if height == 0.9 and charge_ticks == 86:
					_check(absf(pose.torso.rotation.y) > 0.4 and absf(pose.hips.rotation.y) > 0.15, "Torso and hips turn sideways")
					await _capture(expected + "-preparation")
				shot.release_shot(Vector2.ZERO)
				ball.position = player.position + Vector3(side * 0.8, height, -0.65 if side == 0.0 else -0.4)
				shot.previous_ball_position = ball.position
				shot.contact_wait = 0.06
				shot.step(DT)
				_check(ball.strikes.size() == 1, "One automatic physical contact")
				var error: float = player.racket.global_position.distance_to(ball.global_position)
				_check(error < 0.0001, "Pose preserves exact impact")
				_arm_clearance("contact")
				var outgoing: Vector3 = ball.velocity
				var start: Vector3 = player.position
				if height == 0.9 and charge_ticks == 86: await _capture(expected + "-contact")
				for tick in range(40):
					pose.step(DT)
					_arm_clearance("follow-through")
					if tick == 10 and height == 0.9 and charge_ticks == 86: await _capture(expected + "-follow")
				_check(ball.velocity.is_equal_approx(outgoing) and player.position.is_equal_approx(start), "Animation does not change gameplay")
				_check(absf(pose.torso.rotation.y) < 0.001 and absf(pose.hips.rotation.y) < 0.001, "Returns to neutral stance")
				cases.append({"side": expected, "height": height, "preparation_ticks": charge_ticks, "contact_error_m": error})
	var report := {"engine": Engine.get_version_info().string, "failures": failures, "cases": cases, "minimum_forearm_clearance_m": minimum_clearance, "note": "Procedural right-handed placeholder rig. Samples representative preparation/contact/follow paths, not full production skeletal collision guarantees."}
	var file := FileAccess.open("res://../docs/previews/stroke-pose-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Stroke poses: %d cases, min forearm clearance %.4f m, %d failures" % [cases.size(), minimum_clearance, failures.size()])
	for message in failures.slice(0, 8): push_error(message)
	pose.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
