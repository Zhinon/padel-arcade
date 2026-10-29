extends SceneTree
const DT := 1.0 / 120.0
var failures: Array[String] = []
var events: Array[Dictionary] = []
var lab: Node3D
var rival: Node
var player: CharacterBody3D
var ball: CharacterBody3D
var shot: Node
var driver: Node
var frames: Array[Dictionary] = []
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _key(code: int, pressed: bool = true) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.pressed=pressed
	lab.input_adapter._unhandled_input(event)
func _disable_physics(node: Node) -> void:
	node.set_physics_process(false)
	for child in node.get_children(): _disable_physics(child)
func _tick_idle() -> void:
	rival.step(DT)
	player.move_player(Vector2.ZERO,DT)
	rival.player.move_player(rival.movement(),DT)
	if ball.active: ball.step(DT)
	shot.step(DT)
	rival.controller.step(DT)
	lab.impact_feedback.step(DT)
	rival.presentation.step(DT)

func _mirrored_contact(sign_value: float, kind: String, direction: Vector2 = Vector2(0.6,-0.8)) -> Dictionary:
	var actor: CharacterBody3D = player if sign_value>0 else rival.player
	var control: Node = shot if sign_value>0 else rival.controller
	var active_pose: Node = lab.impact_feedback if sign_value>0 else rival.presentation
	active_pose.enabled=true
	active_pose.paused=false
	active_pose.reset_presentation()
	control.enabled=true
	control.paused=false
	actor.reset_position(control.court_vector(Vector3(0,0,5)))
	control.reset_cycle()
	ball.launch(control.court_vector(Vector3(4,1,-3)),Vector3.ZERO)
	control.begin_prepare(control.ShotType.LOB if kind=="lob" else control.ShotType.FLAT)
	var charge: float = 0.3 if kind=="chiquita" else 0.9
	for tick in range(roundi(charge*control.full_preparation/DT)): control.step(DT)
	control.release_shot(Vector2.DOWN if kind=="chiquita" else direction)
	for tick in range(60): control.step(DT)
	var height: float = 2.4 if kind=="smash" else (1.25 if kind=="volley" else 0.9)
	ball.position=control.court_vector(Vector3(0.3,height,4.45))
	ball.velocity=control.court_vector(Vector3(0,-2,8 if kind=="volley" else 0))
	if kind in ["flat","chiquita"]:
		ball.contacts.append({"surface":"floor","position":control.court_vector(Vector3(0,0,3)),"time":0.0})
	control.previous_ball_position=control.court_vector(ball.position)
	var before:=events.size()
	for tick in range(12):
		control.step(DT)
		if events.size()>before: break
	_check(events.size()==before+1,"Mirrored "+kind+" contacts once")
	if events.size()==before: return {}
	var event: Dictionary=events.back().event.duplicate(true)
	_check(event.shot_type==kind,"Mirrored "+kind+" keeps contextual type")
	_check(ball.last_hitter==control.hitter_id,"Hitter identity is preserved on opposite half")
	var pose: Node = lab.impact_feedback if sign_value>0 else rival.presentation
	_check(actor.racket.global_position.distance_to(ball.position)<0.0001,"Mirrored pala matches physical contact")
	var contact: Vector3=actor.position
	var outgoing: Vector3=ball.velocity
	for tick in range(36): pose.step(DT)
	_check(actor.position==contact and ball.velocity==outgoing,"Mirrored presentation never changes physical state")
	event.velocity=control.court_vector(event.velocity)
	event.target=control.court_vector(event.target)
	return event

func _capture_demo() -> void:
	lab.set_practice_mode(true)
	lab._set_practice_paused(false)
	_key(KEY_I)
	_key(KEY_I,false)
	rival.best_rally=0
	var folder:=ProjectSettings.globalize_path("res://../../../work/rival-frames")
	DirAccess.make_dir_recursive_absolute(folder)
	var captured_rival:=false
	for frame in range(180):
		for tick in range(4):
			rival.step(DT)
			if ball.last_hitter != 0 and not rival.waiting_restart:
				if shot.state==shot.State.IDLE: shot.begin_prepare()
				if shot.charging and shot.shot_charge>=0.7: shot.release_shot(Vector2.ZERO)
			player.move_player(Vector2.ZERO,DT)
			rival.player.move_player(rival.movement(),DT)
			if ball.active: ball.step(DT)
			shot.step(DT)
			rival.controller.step(DT)
			lab.impact_feedback.step(DT)
			rival.presentation.step(DT)
		await process_frame
		RenderingServer.force_draw()
		var image:=root.get_texture().get_image()
		image.save_png(folder.path_join("frame-%04d.png" % frame))
		if frame==15: image.save_png(ProjectSettings.globalize_path("res://../docs/previews/rival-training.png"))
		if ball.last_hitter==1 and not captured_rival:
			captured_rival=true
			image.save_png(ProjectSettings.globalize_path("res://../docs/previews/rival-contact.png"))
	_check(captured_rival,"Rendered training shows a real rival return")
	root.size=Vector2i(640,360)
	for frame in range(4): await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/previews/rival-small.png"))
	var panel: Rect2=lab.hud.panel.get_global_rect()
	_check(panel.end.x<=640 and panel.end.y<=360,"Training HUD fits small window")
	_check(lab.hud.title.get_global_rect().end.x<=lab.hud.counter.get_global_rect().position.x,"Small training title does not overlap rally counter")

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await physics_frame
	await process_frame
	lab=current_scene
	lab._set_practice_paused(false)
	rival=lab.trainer
	player=lab.controlled_player
	ball=lab.simulation
	shot=lab.shot_controller
	_disable_physics(lab)
	lab.impact_feedback.set_muted(true)
	rival.presentation.set_muted(true)
	shot.hit.connect(func(event: Dictionary): events.append({"hitter":0,"event":event}))
	rival.controller.hit.connect(func(event: Dictionary): events.append({"hitter":1,"event":event}))
	_check(not rival.enabled and not rival.player.enabled,"Solo practice initially preserved")
	var pad := InputEventJoypadButton.new()
	pad.button_index=JOY_BUTTON_LEFT_SHOULDER
	pad.pressed=true
	_check(InputMap.event_is_action(pad,"padel_training"),"Gamepad LB maps to training toggle")
	_key(KEY_I)
	_key(KEY_I,false)
	_check(rival.enabled and rival.player.enabled and not lab.get_node("Player2").visible and not lab.get_node("Player4").visible,"I starts training and isolates two active players")
	_check(rival.controller.hitter_id==1 and rival.controller.court_sign == -1 and rival.player.speed==player.speed,"Rival uses same reach, movement speed and shot implementation")
	driver=PadelTrainingRival.new()
	driver.controller=shot
	driver.player=player
	driver.ball=ball
	driver.expected_half=1
	var destination:=player.position
	var plan_valid:=false
	var replan:=0.0
	var observed_leg:=-99
	var max_displacement:=0.0
	for tick in range(7200):
		var round_before: int=rival.rounds
		var before_ai: Vector3=rival.player.position
		rival.step(DT)
		var direction:=Vector2.ZERO
		if ball.last_hitter != 0 and not rival.waiting_restart:
			if observed_leg != events.size():
				observed_leg=events.size()
				replan=0
				plan_valid=false
			if shot.is_preparing():
				if shot.charging and shot.shot_charge>=0.7: shot.release_shot(Vector2.ZERO)
			elif shot.recovery == 0:
				replan-=DT
				if replan<=0:
					driver.own_bounces=rival.own_bounces if rival.expected_half>0 else 0
					var plan: Dictionary=driver.predict_intercept()
					plan_valid=not plan.is_empty()
					if plan_valid: destination=plan.position
					replan=0.12
				if plan_valid:
					var offset:=Vector2(destination.x-player.position.x,destination.z-player.position.z)
					if offset.length()<0.18: shot.begin_prepare()
					else: direction=offset.normalized()*minf(1.0,offset.length()/0.35)
		player.move_player(direction,DT)
		rival.player.move_player(rival.movement(),DT)
		if rival.rounds==round_before:
			max_displacement=maxf(max_displacement,Vector2(rival.player.position.x-before_ai.x,rival.player.position.z-before_ai.z).length())
		_check(rival.player.position.z<=-0.59 and rival.player.position.z>=-9.51,"Rival stays on own half")
		if ball.active: ball.step(DT)
		shot.step(DT)
		rival.controller.step(DT)
		lab.impact_feedback.step(DT)
		rival.presentation.step(DT)
		if tick%120==0:
			frames.append({"t":tick*DT,"round":rival.rounds,"hits":rival.rally_hits,"ball":ball.position,"player":player.position,"rival":rival.player.position,"plan":rival.destination,"valid":rival.plan_valid,"state":rival.controller.state,"waiting":rival.waiting_restart,"feedback":lab.hud.last_message})
	_check(rival.returns>=8,"Rival makes repeated real returns: %d" % rival.returns)
	_check(rival.best_rally>=6,"Consecutive rally reaches at least six contacts: %d" % rival.best_rally)
	_check(max_displacement<=player.speed*DT+0.001,"Rival never teleports within a rally: %.5f" % max_displacement)
	var rally_summary: Dictionary={"returns":rival.returns,"best_rally":rival.best_rally,"rounds":rival.rounds}
	# Forecast is read-only, including random stream and contact history.
	var at: Vector3=ball.position
	var speed: Vector3=ball.velocity
	var clock: float=ball.elapsed
	var rng: int=ball.fence_rng.state
	var contacts: int=ball.contacts.size()
	rival.predict_intercept()
	_check(ball.position==at and ball.velocity==speed and ball.elapsed==clock and ball.fence_rng.state==rng and ball.contacts.size()==contacts,"Prediction does not mutate ball, clock, contacts or RNG")
	var mute_event:=InputEventKey.new()
	mute_event.physical_keycode=KEY_M
	mute_event.pressed=true
	lab._input(mute_event)
	_check(not lab.impact_feedback.muted and not rival.presentation.muted,"M unmutes both actors")
	lab._input(mute_event)
	_check(lab.impact_feedback.muted and rival.presentation.muted,"M mutes both actors together")
	# No-input failure ends the rally and starts another, with pause freezing its timer.
	rival.restart_rally()
	player.position.x=2.0
	_key(KEY_R)
	_key(KEY_R,false)
	_check(player.position.is_equal_approx(Vector3(-2.4,0,6.8)) and not rival.waiting_restart,"R starts a fresh training rally with explicit starting placement")
	var starting_round: int=rival.rounds
	var ended:=false
	for tick in range(1200):
		_tick_idle()
		if rival.waiting_restart:
			ended=true
			break
	_check(ended,"Unreturned real feed ends rally")
	if ended:
		lab._set_practice_paused(true)
		var timer: float=rival.restart_remaining
		var rival_at: Vector3=rival.player.position
		for tick in range(120): rival.step(DT)
		_check(rival.paused and rival.controller.paused and rival.restart_remaining==timer and rival.player.position==rival_at,"Pause freezes rival and restart timer")
		lab._set_practice_paused(false)
		for tick in range(240): _tick_idle()
		_check(rival.rounds>starting_round and shot.enabled,"Automatic restart restores human controller")
	var incoming_cases: Array[Dictionary]=[]
	for kind: String in ["flat","lob","chiquita","volley","smash"]:
		for direction: Vector2 in [Vector2.LEFT*0.6,Vector2.ZERO,Vector2.RIGHT*0.6]:
			rival.restart_rally()
			_mirrored_contact(1,kind,direction)
			var before_return: int=rival.returns
			for tick in range(900):
				_tick_idle()
				if rival.returns>before_return or rival.waiting_restart: break
			var returned: bool=rival.returns>before_return
			incoming_cases.append({"kind":kind,"direction":direction,"returned":returned,"ended":rival.waiting_restart,"position":rival.player.position,"last_type":events.back().event.shot_type})
			if kind in ["flat","lob"] and direction==Vector2.ZERO:
				_check(returned,"Rival reaches a normal central "+kind+": "+str(incoming_cases.back()))
	# Reaction and reachable movement have a bounded delay.
	rival.restart_rally()
	ball.launch(Vector3(0,1.5,3),Vector3.ZERO)
	ball.strike(Vector3(0,3,-8),0)
	var reaction_at: Vector3=rival.player.position
	for tick in range(24): _tick_idle()
	_check(rival.player.position.distance_to(reaction_at)<0.01 and not rival.controller.is_preparing(),"Rival cannot react before configured 0.24 s")
	# An unreachable fast shot must not produce a remote or extra hit.
	rival.restart_rally()
	ball.launch(Vector3(4,0.8,-7),Vector3.ZERO)
	ball.strike(Vector3(0,-1,-16),0)
	var return_count: int=rival.returns
	for tick in range(130): _tick_idle()
	_check(rival.returns==return_count,"Impossible distant ball is not returned")
	_key(KEY_I)
	_key(KEY_I,false)
	_check(not rival.enabled and shot.enabled and lab.get_node("Player2").visible and lab.get_node("Player4").visible,"I restores solo mode, including controller after rally end")
	var mirror_cases: Array[Dictionary]=[]
	for kind: String in ["flat","lob","chiquita","volley","smash"]:
		var near:=_mirrored_contact(1,kind)
		var far:=_mirrored_contact(-1,kind)
		if near.is_empty() or far.is_empty(): continue
		_check(near.velocity.distance_to(far.velocity)<0.0001 and near.target.distance_to(far.target)<0.0001 and absf(near.quality-far.quality)<0.0001,"Shared solver symmetry for "+kind)
		mirror_cases.append({"kind":kind,"near":near,"far":far})
	rival.controller.enabled=false
	_key(KEY_I)
	_key(KEY_I,false)
	lab.input_adapter._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	_check(lab.preview_paused and rival.paused,"Focus loss pauses training")
	lab._set_practice_paused(false)
	lab.set_practice_mode(false)
	_check(not rival.enabled and not rival.player.enabled and not rival.controller.enabled,"Laboratory disables all rival gameplay")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture_demo()
	var file:=FileAccess.open("res://../docs/previews/rival-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"seconds":60,"returns":rally_summary.returns,"best_rally":rally_summary.best_rally,"rounds":rally_summary.rounds,"mirrored":mirror_cases,"incoming_cases":incoming_cases,"max_step_m":max_displacement,"failures":failures,"frames":frames,"events":events},"\t"))
	file.close()
	print("Rival checks: %d rally returns, best rally %d, %d mirrored cases, %d failures" % [rally_summary.returns,rally_summary.best_rally,mirror_cases.size(),failures.size()])
	for message in failures.slice(0,8): push_error(message)
	driver.free()
	rival.set_enabled(false)
	await create_timer(0.1).timeout
	quit(0 if failures.is_empty() else 1)
