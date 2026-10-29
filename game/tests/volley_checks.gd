extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var risks: Array[Dictionary] = []
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
			_check(clearance >= -0.008, "%s: %s torso/head clearance %.4f" % [label,mesh.name,clearance])
func _contact(z: float, height: float, dx: float, aim: Vector2, charge: float = 0.9, early: bool = true) -> Dictionary:
	player.reset_position(Vector3(0,0,z))
	shot.reset_cycle()
	lab.input_adapter.reset_buttons()
	pose.reset_presentation()
	ball.launch(Vector3(4,1.6,-5.8),Vector3(0,0,8))
	_key(KEY_J,true)
	if early:
		for tick in range(roundi(charge * shot.full_preparation / DT)):
			shot.step(DT)
			pose.step(DT)
		_key(KEY_J,false)
		for tick in range(30): shot.step(DT)
	ball.position = player.position + Vector3(dx,height,-0.55)
	ball.velocity = Vector3(0,-1,8)
	shot.previous_ball_position = ball.position
	shot.aim = aim
	var before := events.size()
	for tick in range(12):
		shot.step(DT)
		if events.size() > before: break
	_check(events.size() == before+1, "One automatic volley contact")
	if events.size() == before: return {}
	var event: Dictionary = events.back()
	_check(event.shot_type == "volley" and event.touch == 0, "Incoming unbounced flat selects volley, never chiquita")
	_check(player.racket.global_position.distance_to(ball.position) < 0.0001, "Pala coincides with actual volley contact")
	_check(pose.volley_stroke and not pose.overhead_stroke, "Short volley presentation selected")
	_pose_check("contact")
	var at: Vector3 = player.position
	var speed: Vector3 = ball.velocity
	for tick in range(24):
		pose.step(DT)
		_pose_check("follow")
	_check(player.position == at and ball.velocity == speed, "Presentation never changes simulation")
	return event
func _flight(event: Dictionary) -> Dictionary:
	var apex: float = ball.position.y
	for tick in range(500):
		ball.step(DT)
		apex = maxf(apex,ball.position.y)
		if not ball.contacts.is_empty():
			var first: Dictionary = ball.contacts[0]
			return {"height": event.position.y,"charge":event.charge,"quality":event.quality,"defensive":event.defensive,"velocity":event.velocity,"target":event.target,"surface":first.surface,"landing":first.position,"apex":apex,"time":ball.elapsed,"error":Vector2(first.position.x-event.target.x,first.position.z-event.target.z).length()}
	return {"surface":"none"}
func _capture_demo() -> void:
	player.reset_position(Vector3(lab.FEED_LANES[0],0,3))
	lab.feed_lane=0
	_key(KEY_R,true)
	_key(KEY_R,false)
	var folder:=ProjectSettings.globalize_path("res://../../../work/volley-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	var before:=events.size()
	var captured:=false
	for frame in range(60):
		for tick in range(4):
			ball.step(DT)
			if frame==3 and tick==0: _key(KEY_J,true)
			if shot.charging and shot.shot_charge >= 0.9: _key(KEY_J,false)
			shot.aim=Vector2.RIGHT
			shot.step(DT)
			pose.step(DT)
		await process_frame
		RenderingServer.force_draw()
		var image:=root.get_texture().get_image()
		image.save_png(folder.path_join("frame-%04d.png" % frame))
		if frame==22: image.save_png(ProjectSettings.globalize_path("res://../docs/previews/volley-preparation.png"))
		if events.size()>before and not captured:
			captured=true
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/volley-contact.png"))
	_check(captured,"Visual demo completes automatic volley")

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab=current_scene
	lab._set_practice_paused(false)
	player=lab.controlled_player
	ball=lab.simulation
	shot=lab.shot_controller
	pose=lab.impact_feedback
	for node in [lab,player,ball,shot,pose]: node.set_physics_process(false)
	pose.set_muted(true)
	shot.hit.connect(func(event: Dictionary): events.append(event))
	for z: float in [1.5,3.0,5.0]:
		for height: float in [0.5,1.25,2.0]:
			for dx: float in [-0.4,0.4]:
				for aim: Vector2 in [Vector2(-0.6,-0.8),Vector2.ZERO,Vector2(0.6,0.8)]:
					var event:=_contact(z,height,dx,aim)
					if event.is_empty(): continue
					var result:=_flight(event)
					cases.append(result)
					_check(result.surface == "floor" and result.landing.z < 0 and result.error < 0.25,"Prepared volley clears net and hits selected rival floor: "+str(result))
	var good:=_contact(2,1.25,0.3,Vector2.RIGHT)
	var good_speed: float = Vector2(good.velocity.x,good.velocity.z).length()
	var soft:=_contact(2,1.25,0.3,Vector2.RIGHT,0.3)
	_check(Vector2(soft.velocity.x,soft.velocity.z).length() < good_speed, "Prepared low-charge volley remains softer")
	_check(shot.recovery == shot.volley_recovery, "Prepared volley recovers in short configured duration")
	var late:=_contact(2,1.25,0.3,Vector2.RIGHT,0.0,false)
	_check(late.defensive and late.effective_power <= shot.emergency_power and Vector2(late.velocity.x,late.velocity.z).length() < good_speed and absf(late.target.x) < absf(good.target.x),"Late reachable volley is weaker and less directed")
	var defense_flight:=_flight(late)
	_check(defense_flight.surface == "floor" and defense_flight.landing.z < 0, "Late volley can keep rally alive")
	var overloaded:=_contact(2,1.25,0.3,Vector2.DOWN,1.0)
	_check(overloaded.net_risk > 0, "100 percent downward volley preserves net risk")
	var overload_flight:=_flight(overloaded)
	risks.append(overload_flight)
	_check(overload_flight.surface == "net", "Overloaded short volley can hit real net")
	var weak_low:=_contact(2,0.5,0.3,Vector2.DOWN,0.05)
	var weak_low_flight:=_flight(weak_low)
	risks.append(weak_low_flight)
	_check(weak_low_flight.surface == "net", "Insufficient low short volley can hit net despite arc assistance")
	var safe_soft:=_contact(2,1.25,0.3,Vector2.DOWN,0.3)
	var safe_soft_flight:=_flight(safe_soft)
	risks.append(safe_soft_flight)
	_check(safe_soft_flight.surface == "floor" and safe_soft_flight.landing.z < 0, "Well prepared soft short volley still clears net")
	var deep_overload:=_contact(2,0.5,0.8,Vector2.UP,1.0)
	var deep_overload_flight:=_flight(deep_overload)
	risks.append(deep_overload_flight)
	_check(deep_overload_flight.surface == "glass", "Overloaded deep volley can hit rival back glass before floor: "+str(deep_overload_flight))
	for direction: Vector2 in [Vector2.LEFT,Vector2.RIGHT]:
		var wide_overload:=_contact(2,1.25,0.3,direction,1.0)
		var wide_overload_flight:=_flight(wide_overload)
		risks.append(wide_overload_flight)
		_check(wide_overload_flight.surface in ["glass","fence"] and wide_overload_flight.landing.z < 0, "Overloaded angled volley can hit rival side before floor: "+str(wide_overload_flight))
	# Eligibility depends on the incoming leg, not old bounces from a previous stroke.
	shot.reset_cycle()
	ball.launch(Vector3(0,1.25,2),Vector3(0,0,8))
	_check(shot.is_volley_context(),"Incoming flight qualifies")
	ball.contacts.append({"surface":"floor","position":Vector3(0,ball.radius,1),"time":0.1})
	_check(not shot.is_volley_context(),"A bounce on our half selects groundstroke")
	ball.elapsed=0.3
	ball.strike(Vector3(0,0,8),1)
	_check(shot.is_volley_context(),"Previous leg bounce does not block new incoming volley")
	ball.contacts.append({"surface":"floor","position":Vector3(0,ball.radius,-1),"time":0.4})
	_check(shot.is_volley_context(),"Rival floor bounce does not count as our bounce")
	ball.contacts.append({"surface":"floor","position":Vector3(0,ball.radius,1),"time":0.5})
	_check(not shot.is_volley_context(),"Current leg own bounce blocks volley")
	ball.launch(Vector3(0,1.25,2),Vector3(0,0,8))
	shot.shot_kind=shot.ShotType.LOB
	_check(not shot.is_volley_context(),"K preserves lob before bounce")
	shot.shot_kind=shot.ShotType.FLAT
	ball.position.y=2.4
	ball.velocity.y=-2
	_check(not shot.is_volley_context() and shot.is_smash_context(),"High ball preserves smash")
	ball.position.y=0.3
	_check(not shot.is_volley_context(),"Ball too low preserves low ground contact")
	ball.position.y=1.25
	ball.velocity.z=-8
	_check(not shot.is_volley_context(),"Outgoing ball never becomes incoming volley")
	# Real R feeds, without placing the ball at impact.
	var feeds: Array[Dictionary]=[]
	for lane in range(3):
		player.reset_position(Vector3(lab.FEED_LANES[lane],0,3.0))
		lab.feed_lane=lane
		_key(KEY_R,true)
		_key(KEY_R,false)
		var before:=events.size()
		for tick in range(300):
			ball.step(DT)
			if tick==10: _key(KEY_J,true)
			if shot.charging and shot.shot_charge >= 0.9: _key(KEY_J,false)
			shot.step(DT)
			pose.step(DT)
			if events.size()>before: break
		_check(events.size()==before+1 and events.back().shot_type=="volley","Real R feed can be volleyed in each lane")
		if events.size()>before:
			_check(events.back().charge >= 0.86 and not events.back().defensive,"R allows prepared volley at 90 percent")
			feeds.append(_flight(events.back()))
	if "--capture" in OS.get_cmdline_user_args():
		await _capture_demo()
	var file:=FileAccess.open("res://../docs/previews/volley-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"dt":DT,"cases":cases,"feeds":feeds,"risk_checks":risks,"failures":failures,"min_clearance":min_clearance},"\t"))
	file.close()
	print("Volley checks: %d trajectories, %d feeds, %d failures" % [cases.size(),feeds.size(),failures.size()])
	for message in failures.slice(0,8): push_error(message)
	pose.reset_presentation()
	await create_timer(0.1).timeout
	quit(0 if failures.is_empty() else 1)
