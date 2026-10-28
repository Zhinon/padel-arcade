extends SceneTree
## Real contacts and swept ball trajectories; no runtime rival or human playtest.
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var events: Array[Dictionary] = []
var lab: Node3D
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)

func _contact(z: float, height: float, direction: Vector2, charge: float, early: bool = true) -> Dictionary:
	player.reset_position(Vector3(0, 0, z))
	shot.reset_cycle()
	lab.impact_feedback.reset_presentation()
	# Ball waits outside reach while we exercise charging, release and locked preparation.
	ball.launch(Vector3(4, 1, -3), Vector3.ZERO)
	shot.begin_prepare()
	for tick in range(roundi(charge * shot.full_preparation / DT)):
		shot.step(DT)
	shot.release_shot(direction)
	if early:
		for tick in range(80): shot.step(DT)
	var locked_charge: float = shot.shot_charge
	ball.position = player.position + Vector3(0, height, -0.65)
	shot.previous_ball_position = ball.position
	var before: int = events.size()
	shot.step(DT)
	_check(events.size() == before + 1 and ball.strikes.size() == 1, "One automatic contact")
	_check(absf(shot.shot_charge - locked_charge) < 0.00001, "Waiting planted preserves chosen low charge")
	return events.back().duplicate(true) if events.size() > before else {}

func _flight(event: Dictionary) -> Dictionary:
	var start: Vector3 = ball.position
	var net_height := -1.0
	for tick in range(600):
		var previous: Vector3 = ball.position
		ball.step(DT)
		if previous.z > 0 and ball.position.z <= 0:
			net_height = lerpf(previous.y, ball.position.y, previous.z / (previous.z - ball.position.z))
		if not ball.contacts.is_empty():
			var first: Dictionary = ball.contacts[0]
			return {"start": start, "charge": event.charge, "quality": event.quality, "type": event.shot_type, "perfect": event.perfect, "target": event.target, "velocity": event.velocity, "net_height": net_height, "first_surface": first.surface, "landing": first.position, "error_m": Vector2(first.position.x - event.target.x, first.position.z - event.target.z).length()}
	return {"first_surface": "none"}

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab = current_scene
	lab._set_practice_paused(false)
	for connection in lab.input_adapter.focus_lost.get_connections():
		lab.input_adapter.focus_lost.disconnect(connection.callable)
	player = lab.controlled_player
	ball = lab.simulation
	shot = lab.shot_controller
	for node in [lab, player, ball, shot, lab.impact_feedback]: node.set_physics_process(false)
	shot.hit.connect(func(event: Dictionary): events.append(event))
	for z: float in [1.3, 5.0, 9.0]:
		for height: float in [0.3, 0.9, 1.8]:
			for x: float in [-0.6, 0.0, 0.6]:
				for charge: float in [0.2, 0.4]:
					var event := _contact(z, height, Vector2(x, 0.8 if x != 0 else 1.0), charge)
					if event.is_empty(): continue
					var result := _flight(event)
					cases.append(result)
					_check(not event.defensive and event.shot_type == "chiquita", "Early low charge remains controlled chiquita")
					_check(result.first_surface == "floor" and result.landing.z < 0, "Chiquita clears net before rival floor: %s" % result)
					_check(result.error_m < 0.25 and result.landing.z > -3.0, "Chiquita lands near short intended placement")
					_check(Vector2(event.velocity.x, event.velocity.z).length() <= shot.touch_horizontal_speed + 0.001, "Soft shot has bounded horizontal speed")
	var early := _contact(6.8, 0.9, Vector2(0.6, 0.8), 0.15)
	var late := _contact(6.8, 0.9, Vector2(0.6, 0.8), 0.15, false)
	_check(early.perfect and not early.defensive and late.defensive and not late.perfect, "Same low charge distinguishes well prepared shot from late defense")
	_check(absf(early.target.x) > absf(late.target.x) + 1.0, "Late contact loses lateral control")
	# A minimal late attempt may fail physically at the net, without random error.
	var weak := _contact(6.8, 0.3, Vector2.DOWN, 0.0, false)
	var weak_flight := _flight(weak)
	_check(weak_flight.first_surface == "net", "Insufficient late short shot can contact net: %s" % weak_flight)
	var good := _contact(6.8, 0.9, Vector2.DOWN, 0.25)
	var good_flight := _flight(good)
	var drive := _contact(6.8, 0.9, Vector2.DOWN, 0.9)
	var drive_flight := _flight(drive)
	_check(good.perfect and drive.perfect and drive.shot_type == "drive", "Excellent soft shot and 90 percent drive both recognized")
	_check(good.velocity.length() < drive.velocity.length() and good_flight.landing.z > drive_flight.landing.z + 1.0, "Chiquita slower and shorter than prepared drive")
	_check(good_flight.net_height >= 1.10 and good_flight.net_height < 1.25, "Comfortable chiquita passes low above net")
	var transitions: Array[Dictionary] = []
	for charge: float in [0.4, 0.45, 0.5, 0.55, 0.6, 0.65]:
		for downward: float in [0.2, 0.4, 0.6, 0.8]:
			var transition := _flight(_contact(6.8, 0.9, Vector2(0, downward), charge))
			transitions.append(transition)
			_check(transition.first_surface == "floor" and transition.landing.z < 0 and transition.error_m < 0.25, "Intermediate aim/charge keeps predictable placement: %s" % transition)
	var feeds: Array[Dictionary] = []
	# Exercise the real R/T feed and moving incoming ball, with no contact teleport.
	for lane in range(3):
		player.reset_position(Vector3(lab.FEED_LANES[lane], 0, 6.8))
		lab.feed_lane = lane
		lab.feed_practice_ball()
		var before: int = events.size()
		for tick in range(300):
			ball.step(DT)
			if tick == 30: shot.begin_prepare()
			if shot.charging and shot.shot_charge >= 0.25: shot.release_shot(Vector2.DOWN)
			shot.aim = Vector2.DOWN
			shot.step(DT)
			if events.size() > before: break
		_check(events.size() == before + 1, "Real feed produces automatic short contact in lane %d" % lane)
		if events.size() > before:
			# Keep only outgoing collision events, excluding incoming first bounce.
			ball.contacts.clear()
			var feed_result := _flight(events.back())
			feeds.append(feed_result)
			_check(events.back().shot_type == "chiquita" and feed_result.first_surface == "floor" and feed_result.landing.z < 0 and feed_result.landing.z > -3, "Real feed chiquita lands short in opposing court")
	if "--capture" in OS.get_cmdline_user_args():
		shot.hits = 0
		_contact(6.8, 0.9, Vector2.DOWN, 0.25)
		lab.aim_marker.position = Vector3(shot.target.x, 0.025, shot.target.z)
		var folder := ProjectSettings.globalize_path("res://../../../work/chiquita-frames")
		DirAccess.make_dir_recursive_absolute(folder)
		for frame in range(75):
			for tick in range(4):
				ball.step(DT)
				shot.step(DT)
				lab.impact_feedback.step(DT)
			await process_frame
			RenderingServer.force_draw()
			root.get_texture().get_image().save_png(folder.path_join("frame-%04d.png" % frame))
			if frame == 25:
				root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/chiquita.png"))
	var report := {"engine": Engine.get_version_info().string, "dt": DT, "failures": failures, "cases": cases, "transitions": transitions, "feeds": feeds, "early": early, "late": late, "weak": weak_flight, "comfortable": good_flight, "drive": drive_flight, "note": "Synthetic contacts plus three real practice feeds and swept trajectories. Static opponents; tactical effect and human feel pending."}
	var file := FileAccess.open("res://../docs/previews/chiquita-checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("Chiquita checks: %d trajectories, %d failures" % [cases.size(), failures.size()])
	for message in failures.slice(0, 10): push_error(message)
	lab.impact_feedback.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
