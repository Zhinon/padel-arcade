extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var events: Array[Dictionary] = []
var lab: Node3D
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node
var pose: Node
var min_clearance := INF

func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	lab.input_adapter._unhandled_input(event)
func _pose_check(label: String) -> void:
	var head: Node3D = pose.torso.get_node("Head")
	for mesh: MeshInstance3D in [pose.forearm, pose.off_fore, pose.arm, pose.off_upper]:
		var half_axis: Vector3 = mesh.basis.y * 0.2
		var radius := 0.055 if mesh in [pose.forearm, pose.off_fore] else 0.065
		for i in range(13):
			var world: Vector3 = player.visual.to_global(mesh.position + half_axis * lerpf(-1, 1, i / 12.0))
			var local: Vector3 = pose.torso.to_local(world)
			var axis := Vector3(0, clampf(local.y, -0.01, 0.21), 0)
			var clearance := minf(local.distance_to(axis) - 0.24 - radius, world.distance_to(head.global_position) - 0.18 - radius)
			min_clearance = minf(min_clearance, clearance)
			_check(clearance >= -0.008, "%s: %s stays outside torso/head (%.4f m)" % [label, mesh.name, clearance])
func _contact(z: float, height: float, dx: float, direction: Vector2, charge: float = 0.9, early: bool = true) -> Dictionary:
	player.reset_position(Vector3(0, 0, z))
	shot.reset_cycle()
	pose.reset_presentation()
	ball.launch(Vector3(3, 3.5, 1), Vector3.ZERO)
	_key(KEY_SPACE, true)
	for tick in range(roundi(charge * shot.full_preparation / DT)):
		shot.step(DT)
		pose.step(DT)
		_pose_check("windup")
	_key(KEY_SPACE, false)
	if early:
		for tick in range(30):
			shot.step(DT)
			pose.step(DT)
	ball.position = player.position + Vector3(dx, height, -0.35)
	ball.velocity = Vector3(0, -4, 0)
	shot.previous_ball_position = ball.position
	shot.aim = direction
	var before: int = events.size()
	for tick in range(12):
		shot.step(DT)
		if events.size() > before: break
		pose.step(DT)
	_check(events.size() == before + 1 and ball.strikes.size() == 1, "One contextual contact")
	if events.size() == before: return {}
	var result: Dictionary = events.back().duplicate(true)
	_check(result.shot_type == "smash", "High reachable flat becomes smash")
	_check(player.racket.global_position.distance_to(ball.global_position) < 0.0001 and pose.overhead_stroke, "Overhead pose at exact physical impact")
	_pose_check("contact")
	var body: Vector3 = player.position
	var velocity: Vector3 = ball.velocity
	for tick in range(45):
		pose.step(DT)
		_pose_check("follow")
	_check(player.position.is_equal_approx(body) and ball.velocity.is_equal_approx(velocity) and player.racket.transform.is_equal_approx(pose.racket_rest), "Pose preserves simulation and returns to rest")
	return result
func _flight(event: Dictionary) -> Dictionary:
	for tick in range(600):
		ball.step(DT)
		if not ball.contacts.is_empty():
			var first: Dictionary = ball.contacts[0]
			return {"surface": first.surface, "landing": first.position, "target": event.target, "velocity": event.velocity, "height": event.position.y, "charge": event.charge, "quality": event.quality, "defensive": event.defensive, "error_m": Vector2(first.position.x - event.target.x, first.position.z - event.target.z).length()}
	return {"surface": "none"}

func _capture_pose(label: String) -> void:
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/smash-" + label + ".png"))
	var original: Transform3D = lab.camera.transform
	var old_fov: float = lab.camera.fov
	lab.camera.position = player.position + Vector3(3.0, 2.6, 2.0)
	lab.camera.look_at(player.position + Vector3(0,1.5,-0.1))
	lab.camera.fov = 48
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/smash-" + label + "-close.png"))
	lab.camera.transform = original
	lab.camera.fov = old_fov
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab._set_practice_paused(false)
	for connection in lab.input_adapter.focus_lost.get_connections(): lab.input_adapter.focus_lost.disconnect(connection.callable)
	player = lab.controlled_player
	ball = lab.simulation
	shot = lab.shot_controller
	pose = lab.impact_feedback
	for node in [lab, player, ball, shot, pose]: node.set_physics_process(false)
	pose.set_muted(true)
	shot.hit.connect(func(event: Dictionary): events.append(event))
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_RIGHT_SHOULDER
	pad.pressed = true
	_check(InputMap.event_is_action(pad,"padel_smash_feed"), "RB maps to incoming practice lob")
	for z: float in [2.0, 5.0, 8.5]:
		for height: float in [2.2, 2.4, 2.6]:
			for dx: float in [-0.35, 0.35]:
				for direction: Vector2 in [Vector2(-0.6,-0.8), Vector2.ZERO, Vector2(0.6,0.8)]:
					var event := _contact(z, height, dx, direction)
					if event.is_empty(): continue
					var result := _flight(event)
					cases.append(result)
					_check(not event.defensive and event.velocity.y < 0, "Prepared smash is descending")
					_check(result.surface == "floor" and result.landing.z < 0 and result.error_m < 0.25, "Prepared smash reaches opposing floor before enclosure: %s" % result)
	var good := _contact(6.8, 2.4, 0.25, Vector2.RIGHT)
	var good_flight := _flight(good)
	var late := _contact(6.8, 2.4, 0.25, Vector2.RIGHT, 0.0, false)
	_check(late.defensive and late.velocity.length() < good.velocity.length() * 0.65 and absf(late.target.x) < absf(good.target.x), "Late overhead survives with weaker, less directed return")
	var late_flight := _flight(late)
	var short_overload := _flight(_contact(6.8,2.2,0.6,Vector2.DOWN,1.0))
	var long_overload := _flight(_contact(6.8,2.2,0.6,Vector2.UP,1.0))
	_check(short_overload.surface == "net" and long_overload.surface in ["glass","fence"], "Smash overload keeps directional net/enclosure risk")
	# Too high, behind, rising, or horizontally distant: cannot magically smash.
	for offset: Vector3 in [Vector3(0,3.1,-0.35), Vector3(0,2.4,0.4), Vector3(1.5,2.4,-0.35)]:
		shot.reset_cycle()
		ball.launch(player.position + offset, Vector3.ZERO)
		shot.begin_prepare()
		shot.step(DT)
		_check(ball.strikes.is_empty(), "Unreachable overhead stays unhit")
	shot.reset_cycle()
	ball.launch(player.position + Vector3(0,2.4,-0.35), Vector3(0,3,0))
	shot.begin_prepare()
	shot.step(DT)
	_check(ball.strikes.is_empty(), "Rising high ball waits instead of premature smash")
	shot.reset_cycle()
	ball.launch(player.position + Vector3(0.25,2.4,-0.35),Vector3(0,-4,0))
	_key(KEY_E,true)
	shot.step(DT)
	_check(ball.strikes.is_empty() and shot.shot_kind == shot.ShotType.LOB, "Globo button never becomes smash")
	shot.reset_cycle()
	var feeds: Array[Dictionary] = []
	for lane in range(3):
		player.reset_position(Vector3(lab.FEED_LANES[lane],0,6.8))
		lab.feed_lane = lane
		_key(KEY_H,true)
		_key(KEY_H,false)
		var before: int = events.size()
		for tick in range(400):
			ball.step(DT)
			if tick == 40: _key(KEY_SPACE,true)
			if shot.charging and shot.shot_charge >= 0.9: _key(KEY_SPACE,false)
			shot.step(DT)
			pose.step(DT)
			if events.size() > before: break
		_check(events.size() == before + 1 and events.back().shot_type == "smash", "H supplies real smash in lane %d" % lane)
		if events.size() > before:
			ball.contacts.clear()
			feeds.append(_flight(events.back()))
	if "--capture" in OS.get_cmdline_user_args():
		shot.hits = 0
		player.reset_position(Vector3(-2.4,0,6.8))
		lab.feed_lane = 0
		_key(KEY_H,true)
		_key(KEY_H,false)
		var captured_preparation := false
		var captured_contact := false
		var captured_follow := false
		var folder := ProjectSettings.globalize_path("res://../../../work/smash-frames")
		DirAccess.make_dir_recursive_absolute(folder)
		for frame in range(150):
			for tick in range(4):
				ball.step(DT)
				if frame == 10 and tick == 0: _key(KEY_SPACE,true)
				if shot.charging and shot.shot_charge >= 0.9: _key(KEY_SPACE,false)
				shot.step(DT)
				if shot.hits > 0 and not captured_contact:
					captured_contact = true
					await _capture_pose("contact")
				pose.step(DT)
				if shot.is_preparing() and ball.position.z > 5.0 and not captured_preparation:
					captured_preparation = true
					await _capture_pose("preparation")
				if shot.hits > 0 and pose.elapsed >= 0.10 and not captured_follow:
					captured_follow = true
					await _capture_pose("follow")
			lab.aim_marker.position = Vector3(shot.target.x,0.025,shot.target.z)
			await process_frame
			RenderingServer.force_draw()
			root.get_texture().get_image().save_png(folder.path_join("frame-%04d.png" % frame))
	var file := FileAccess.open("res://../docs/previews/smash-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"dt":DT,"failures":failures,"cases":cases,"good":good_flight,"late":late_flight,"short_overload":short_overload,"long_overload":long_overload,"feeds":feeds,"minimum_arm_clearance_m":min_clearance,"note":"Synthetic contacts plus real H feeds; no human playtest or runtime opponent."},"\t"))
	file.close()
	print("Smash checks: %d trajectories, %d feeds, %d failures" % [cases.size(),feeds.size(),failures.size()])
	for message in failures.slice(0,10): push_error(message)
	pose.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
