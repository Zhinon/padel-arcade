extends SceneTree
const DT := 1.0/120.0
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var events: Array[Dictionary] = []
var lab: Node3D
var player: CharacterBody3D
var ball: PadelBallSimulation
var shot: Node
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	lab.input_adapter._unhandled_input(event)
func _contact(x: float,z: float,height: float,aim: Vector2,charge: float=0.9,dx: float=0.25,lob_first: bool=false) -> Dictionary:
	player.reset_position(Vector3(x,0,z))
	shot.reset_cycle()
	lab.input_adapter.reset_buttons()
	lab.impact_feedback.reset_presentation()
	ball.launch(Vector3(4,3.5,0.3),Vector3.ZERO)
	_key(KEY_E if lob_first else KEY_SPACE,true)
	shot.step(0.025)
	var initial: float = shot.charge_time
	_key(KEY_SPACE if lob_first else KEY_E,true)
	_check(shot.shot_kind == shot.ShotType.SPECIAL and shot.charge_time == initial,"Chord preserves first button charge")
	while shot.shot_charge < charge and shot.charging: shot.step(DT)
	_key(KEY_SPACE,false)
	_key(KEY_E,false)
	_check(shot.state == shot.State.LOCKED,"First chord release fixes charge; second cannot restart")
	for tick in range(30): shot.step(DT)
	ball.position=player.position+Vector3(dx,height,-0.35)
	ball.velocity=Vector3(0,-4,0)
	shot.previous_ball_position=ball.position
	shot.aim=aim
	var at: Vector3=ball.position
	var clock: float=ball.elapsed
	var rng: int=ball.fence_rng.state
	var before: int=events.size()
	for tick in range(12):
		shot.step(DT)
		if events.size()>before: break
	_check(events.size()==before+1 and ball.strikes.size()==1,"Chord produces exactly one auto contact")
	_check(ball.position.is_equal_approx(at) and ball.elapsed==clock and ball.fence_rng.state==rng,"Search/strike preserve ball position, time and RNG")
	_check(player.racket.global_position.distance_to(ball.global_position)<0.0001,"Racket meets physical contact for special shot")
	return events.back().duplicate(true)
func _flight(event: Dictionary) -> Dictionary:
	var exit_point:=Vector3.ZERO
	var exit_kind:=""
	var exit_side:=0.0
	for tick in range(600):
		var previous: Vector3=ball.position
		ball.step(DT)
		if absf(ball.position.x)>=5 and absf(previous.x)<5:
			var plane:=signf(ball.position.x)*5
			exit_point=previous.lerp(ball.position,(plane-previous.x)/(ball.position.x-previous.x))
			exit_kind="x3"
			exit_side=signf(plane)
		elif ball.position.z<=-10 and previous.z>-10:
			exit_point=previous.lerp(ball.position,(-10-previous.z)/(ball.position.z-previous.z))
			exit_kind="x4"
		if absf(ball.position.x)>5.2 or ball.position.z < -10.2: break
	var surfaces: Array[String]=[]
	for contact: Dictionary in ball.contacts: surfaces.append(contact.surface)
	return {"type":event.shot_type,"position":event.position,"velocity":event.velocity,"charge":event.charge,"quality":event.quality,"surfaces":surfaces,"exit_kind":exit_kind,"exit":exit_point,"exit_side":exit_side,"plan_ms":event.special.get("search_ms",0)}

func _capture_demo(kind: String,direction: Vector2) -> void:
	player.reset_position(Vector3(-2.4,0,1.6))
	lab.feed_lane=0
	shot.hits=0
	_key(KEY_H,true)
	_key(KEY_H,false)
	var folder:=ProjectSettings.globalize_path("res://../../../work/"+kind+"-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	var captured_exit:=false
	for frame in range(90):
		for tick in range(4):
			ball.step(DT)
			if frame==10 and tick==0:
				_key(KEY_SPACE,true)
				_key(KEY_E,true)
			if shot.charging and shot.shot_charge>=0.9:
				_key(KEY_SPACE,false)
				_key(KEY_E,false)
			shot.aim=direction
			shot.step(DT)
			lab.impact_feedback.step(DT)
		lab.aim_marker.position=Vector3(shot.target.x,0.025,shot.target.z)
		await process_frame
		RenderingServer.force_draw()
		var image:=root.get_texture().get_image()
		image.save_png(folder.path_join("frame-%04d.png" % frame))
		if not captured_exit and (absf(ball.position.x)>5 or ball.position.z < -10):
			captured_exit=true
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/"+kind+"-exit.png"))
	_check(captured_exit,"Rendered demo completes physical "+kind+" exit")
func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab=current_scene
	lab._set_practice_paused(false)
	for connection in lab.input_adapter.focus_lost.get_connections(): lab.input_adapter.focus_lost.disconnect(connection.callable)
	player=lab.controlled_player
	ball=lab.simulation
	shot=lab.shot_controller
	for node in [lab,player,ball,shot,lab.impact_feedback]: node.set_physics_process(false)
	lab.impact_feedback.set_muted(true)
	shot.hit.connect(func(event: Dictionary): events.append(event))
	for x: float in [-2.4,0,2.4]:
		for z: float in [1.2,1.8]:
			for height: float in [2.4,2.6]:
				for aim: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
					var event:=_contact(x,z,height,aim)
					var result:=_flight(event)
					cases.append(result)
					var expected:="x4" if aim.y<0 else "x3"
					_check(event.shot_type==expected and result.exit_kind==expected,"Direction selects and physically completes "+expected+": "+str(result))
					_check(result.surfaces==(["floor"] if expected=="x4" else ["floor","glass"]),"Correct physical contact order before exit: "+str(result))
					_check(result.exit.y > (4.0 if expected=="x4" else 3.0)+ball.radius,"Ball clears actual enclosure height")
					if expected=="x3": _check(result.exit.z<0 and result.exit.z > -8 and result.exit_side==signf(aim.x),"Chosen lateral exit occurs above 3m section")
	for condition: Dictionary in [{"z":6.8,"h":2.4,"charge":0.9,"aim":Vector2.RIGHT},{"z":1.5,"h":0.9,"charge":0.9,"aim":Vector2.RIGHT},{"z":1.5,"h":2.4,"charge":0.5,"aim":Vector2.RIGHT},{"z":1.5,"h":2.4,"charge":1.0,"aim":Vector2.RIGHT},{"z":1.5,"h":2.4,"charge":0.9,"aim":Vector2.ZERO},{"z":1.5,"h":2.4,"charge":0.9,"aim":Vector2.DOWN}]:
		var event:=_contact(0,condition.z,condition.h,condition.aim,condition.charge)
		_check(event.shot_type not in ["x3","x4"],"Unqualified attempt falls back to ordinary shot")
	var poor:=_contact(0,1.5,2.16,Vector2.RIGHT,0.9,0.6)
	_check(poor.quality < shot.special_quality and poor.shot_type=="smash","90 percent alone cannot override poor positioning/contact")
	var reversed:=_contact(0,1.5,2.4,Vector2.UP,0.9,0.25,true)
	_check(reversed.shot_type=="x4","Chord works when lob button arrives first")
	_key(KEY_SPACE,true)
	_check(not shot.is_preparing(),"New press during recovery cannot repeat special contact")
	# Late second button retains existing type-switch behavior, not special chord.
	shot.reset_cycle()
	lab.input_adapter.reset_buttons()
	ball.launch(Vector3(4,3.5,0.3),Vector3.ZERO)
	_key(KEY_SPACE,true)
	shot.step(0.2)
	_key(KEY_E,true)
	_check(shot.shot_kind==shot.ShotType.LOB and shot.shot_charge==0,"Late second button switches to fresh lob")
	_key(KEY_SPACE,false)
	_check(shot.charging,"Old release does not lock switched lob")
	lab._set_practice_paused(true)
	_check(not lab.input_adapter.flat_down and not lab.input_adapter.lob_down,"Pause clears chord flags")
	lab._set_practice_paused(false)
	var feeds: Array[Dictionary]=[]
	for aim: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
		player.reset_position(Vector3(-2.4,0,1.6))
		lab.feed_lane=0
		_key(KEY_H,true)
		_key(KEY_H,false)
		var before: int=events.size()
		for tick in range(400):
			ball.step(DT)
			if tick==30:
				_key(KEY_SPACE,true)
				_key(KEY_E,true)
			if shot.charging and shot.shot_charge>=0.9:
				_key(KEY_SPACE,false)
				_key(KEY_E,false)
			shot.aim=aim
			shot.step(DT)
			if events.size()>before: break
		_check(events.size()>before and events.back().shot_type in ["x3","x4"],"Near-net H feed produces special shot")
		if events.size()>before:
			ball.contacts.clear()
			feeds.append(_flight(events.back()))
	if "--capture" in OS.get_cmdline_user_args():
		await _capture_demo("x3",Vector2.RIGHT)
		await _capture_demo("x4",Vector2.UP)
	var file:=FileAccess.open("res://../docs/previews/special-smash-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"dt":DT,"failures":failures,"cases":cases,"feeds":feeds,"note":"Physical swept exits and actual contacts; launch prediction only, no spin simulation, no automatic point award or external play."},"\t"))
	file.close()
	print("Special smash checks: %d cases, %d feeds, %d failures" % [cases.size(),feeds.size(),failures.size()])
	for message in failures.slice(0,8): push_error(message)
	lab.impact_feedback.reset_presentation()
	await create_timer(0.25).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
