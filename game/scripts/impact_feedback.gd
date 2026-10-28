class_name PadelImpactFeedback
extends Node3D
## Presentation only: consumes the authoritative hit; never changes simulation/input.
const SOUNDS := {
	"normal": preload("res://audio/impact-normal.wav"),
	"perfect": preload("res://audio/impact-perfect.wav"),
	"defense": preload("res://audio/impact-defense.wav"),
}
@export var volume_db: float = -8.0
@export var follow_duration: float = 0.24
@export var flash_duration: float = 0.18
var player: CharacterBody3D
var controller: Node
var enabled: bool = false
var paused: bool = false
var muted: bool = false
var audio: AudioStreamPlayer
var flash: MeshInstance3D
var flash_material: StandardMaterial3D
var arm: MeshInstance3D
var torso: Node3D
var hips: Node3D
var forearm: MeshInstance3D
var elbow: MeshInstance3D
var off_upper: MeshInstance3D
var off_fore: MeshInstance3D
var off_elbow: MeshInstance3D
var shot_side: String = "forehand"
var stance_yaw: float = 0.0
var contact_yaw: float = 0.0
@export var stance_turn_speed: float = 14.0
@export var elbow_clearance: float = 0.42
var racket_rest: Transform3D
var elapsed: float = 1.0
var pending_contact: bool = false
var contact_local := Vector3.ZERO
var follow_side: float = 1.0
var last_kind: String = "normal"
var presented_hits: int = 0
var sound_requests: int = 0

func _ready() -> void:
	process_physics_priority = 30
	racket_rest = player.racket.transform
	torso = player.visual.get_node("TorsoPivot")
	hips = player.visual.get_node("HipsPivot")
	arm = player.visual.get_node("UpperArmRight")
	forearm = player.visual.get_node("ForeArmRight")
	elbow = player.visual.get_node("ElbowRight")
	off_upper = player.visual.get_node("UpperArmLeft")
	off_fore = player.visual.get_node("ForeArmLeft")
	off_elbow = player.visual.get_node("ElbowLeft")
	audio = AudioStreamPlayer.new()
	audio.name = "ImpactAudio"
	audio.volume_db = volume_db
	add_child(audio)
	flash = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.18
	ring.outer_radius = 0.24
	flash.mesh = ring
	flash.rotation.x = PI / 2.0
	flash_material = StandardMaterial3D.new()
	flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_material.no_depth_test = true
	flash_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = flash_material
	flash.visible = false
	add_child(flash)
	controller.hit.connect(present_hit)

func present_hit(event: Dictionary) -> void:
	if not enabled or paused:
		return
	last_kind = "perfect" if event.perfect else ("defense" if event.defensive else "normal")
	presented_hits += 1
	elapsed = 0.0
	pending_contact = true
	_select_side(event.position)
	follow_side = 1.0 if shot_side == "forehand" else -1.0
	contact_yaw = _desired_yaw(event.position)
	stance_yaw = contact_yaw
	_apply_body(stance_yaw, 0.06 if last_kind == "defense" else -0.06)
	contact_local = player.visual.to_local(event.position)
	# Apply the physical contact pose without delaying the hit.
	player.racket.position = contact_local
	player.racket.rotation = Vector3.ZERO
	_update_arm()
	flash.position = event.position
	flash.scale = Vector3.ONE
	flash_material.albedo_color = _color()
	flash.visible = true
	player.selection_ring.material_override.albedo_color = _color()
	if not muted:
		audio.stream = SOUNDS[last_kind]
		audio.volume_db = volume_db
		audio.play()
		sound_requests += 1

func _color() -> Color:
	return Color("c7ff64") if last_kind == "perfect" else (Color("ffb76b") if last_kind == "defense" else Color("a5e9ff"))

func _physics_process(delta: float) -> void:
	step(delta)

func step(delta: float) -> void:
	if not enabled or paused:
		return
	if pending_contact:
		pending_contact = false
		return
	elapsed += delta
	if elapsed < follow_duration:
		var t := clampf(elapsed / follow_duration, 0.0, 1.0)
		# Follow across the front of the torso; avoid a straight cut through it.
		stance_yaw = lerp_angle(contact_yaw, -contact_yaw * 0.2, smoothstep(0.0, 1.0, t))
		_apply_body(stance_yaw, -0.06 * (1.0 - t))
		var across := Vector3(-follow_side * (0.62 if last_kind == "perfect" else 0.46), 0.38, -0.55)
		var follow: Vector3 = player.visual.to_local(torso.to_global(across))
		var desired := contact_local.lerp(follow, smoothstep(0.0, 0.55, t))
		desired = desired.lerp(racket_rest.origin, smoothstep(0.6, 1.0, t))
		player.racket.position = _outside_torso(desired, 0.46)
		player.racket.rotation = Vector3(0, follow_side * sin(t * PI) * 0.8, 0)
		player.selection_ring.material_override.albedo_color = _color()
	elif player.preparing:
		_select_side(controller.ball.position)
		stance_yaw = lerp_angle(stance_yaw, _desired_yaw(controller.ball.position), minf(delta * stance_turn_speed, 1.0))
		_apply_body(stance_yaw, -0.03)
		var charge: float = controller.shot_charge
		var side := 1.0 if shot_side == "forehand" else -1.0
		var windup_torso := Vector3(side * 0.50, 0.02 + charge * 0.12, -0.48)
		var windup: Vector3 = player.visual.to_local(torso.to_global(windup_torso))
		var distance: float = Vector2(controller.ball.position.x - player.position.x, controller.ball.position.z - player.position.z).length()
		var arrival := clampf((2.0 - distance) / 1.2, 0.0, 1.0)
		if controller.ball.position.y >= controller.minimum_height and controller.ball.position.y <= controller.maximum_height:
			var approaching: Vector3 = player.visual.to_local(controller.ball.position + controller.ball.velocity * 0.025)
			windup = windup.lerp(approaching, arrival)
		player.racket.position = _outside_torso(player.racket.position.lerp(windup, minf(delta * 20.0, 1.0)), 0.46)
		player.racket.rotation = Vector3(0, -side * 0.6, side * 0.12)
	else:
		stance_yaw = 0.0
		_apply_body(0.0, 0.0)
		player.racket.transform = racket_rest
	_update_arm()
	flash.visible = elapsed < flash_duration
	if flash.visible:
		var progress := elapsed / flash_duration
		flash.scale = Vector3.ONE * lerpf(1.0, 2.2, progress)
		var color := _color()
		color.a = 1.0 - progress
		flash_material.albedo_color = color

func _select_side(ball_at: Vector3) -> void:
	# Fixed right-handed prototype, with a dead zone to prevent pose flicker.
	var dx := ball_at.x - player.position.x
	if dx < -0.15:
		shot_side = "backhand"
	elif dx > 0.15:
		shot_side = "forehand"

func _desired_yaw(ball_at: Vector3) -> float:
	var delta := ball_at - player.position
	var facing := atan2(-delta.x, -delta.z)
	var side_angle := -0.95 if shot_side == "forehand" else 1.15
	return facing if delta.z > 0.0 else lerp_angle(side_angle, facing, 0.3)

func _apply_body(yaw: float, lean: float) -> void:
	torso.rotation = Vector3(lean, yaw, 0)
	hips.rotation.y = yaw * 0.48
	for side: float in [-1.0, 1.0]:
		var label := "Left" if side < 0 else "Right"
		var leg: Node3D = hips.get_node("Leg" + label)
		var foot: Node3D = hips.get_node("Foot" + label)
		var step_z := side * sin(yaw) * 0.13
		leg.position = Vector3(side * 0.16, -0.23, step_z)
		foot.position = Vector3(side * 0.16, -0.58, step_z - 0.06)
		foot.rotation.y = yaw * 0.18

func _outside_torso(at: Vector3, margin: float) -> Vector3:
	var local := torso.to_local(player.visual.to_global(at))
	var axis := Vector3(0, clampf(local.y, -0.01, 0.21), 0)
	var radial := local - axis
	if radial.length() < margin:
		if radial.length() < 0.001:
			radial = Vector3.FORWARD
		local = axis + radial.normalized() * margin
	return player.visual.to_local(torso.to_global(local))

func _limb(mesh: MeshInstance3D, start: Vector3, end: Vector3) -> void:
	var direction := end - start
	mesh.position = (start + end) * 0.5
	if direction.length() > 0.001:
		mesh.quaternion = Quaternion(Vector3.UP, direction.normalized())
		mesh.scale = Vector3(1, direction.length() / 0.4, 1)

func _update_arm() -> void:
	var hand: Vector3 = player.racket.position + Vector3(0, -0.14, 0)
	var hand_local := torso.to_local(player.visual.to_global(hand))
	# The right elbow stays outside the right/front edge, including on backhand.
	var elbow_local := Vector3(maxf(0.36, (hand_local.x + 0.3) * 0.5), clampf((hand_local.y + 0.28) * 0.5 - 0.08, -0.25, 0.28), minf(-elbow_clearance, hand_local.z * 0.55))
	var shoulder: Vector3 = player.visual.to_local(torso.to_global(Vector3(0.3, 0.28, 0)))
	var support := Vector3(-0.45, -0.10, -0.24)
	if shot_side == "backhand" and (player.preparing or elapsed < follow_duration):
		support = hand_local + Vector3(-0.07, 0.04, -0.04)
	var off_elbow_local := Vector3(minf(-0.36, support.x - 0.12), clampf((support.y + 0.28) * 0.5 - 0.08, -0.25, 0.28), minf(-elbow_clearance, support.z * 0.55))
	# Rest is a relaxed hanging arm, not the clearance pose used for a stroke.
	# Blend during the end of follow-through so the elbows do not snap back.
	var rest_weight := 0.0
	if not player.preparing:
		rest_weight = smoothstep(0.6, 1.0, elapsed / follow_duration)
	support = support.lerp(Vector3(-0.37, -0.35, -0.08), rest_weight)
	var right_relax := rest_weight * smoothstep(0.2, 0.4, hand_local.x)
	var left_relax := rest_weight * smoothstep(0.2, 0.36, -support.x)
	elbow_local = elbow_local.lerp(Vector3(0.38, -0.04, -0.04), right_relax)
	off_elbow_local = off_elbow_local.lerp(Vector3(-0.36, -0.04, -0.01), left_relax)
	elbow.position = player.visual.to_local(torso.to_global(elbow_local))
	_limb(arm, shoulder, elbow.position)
	_limb(forearm, elbow.position, hand)
	var off_shoulder: Vector3 = player.visual.to_local(torso.to_global(Vector3(-0.3, 0.28, 0)))
	off_elbow.position = player.visual.to_local(torso.to_global(off_elbow_local))
	_limb(off_upper, off_shoulder, off_elbow.position)
	_limb(off_fore, off_elbow.position, player.visual.to_local(torso.to_global(support)))

func _unhandled_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed("padel_mute") and not event.is_echo():
		set_muted(not muted)
		get_viewport().set_input_as_handled()

func set_muted(value: bool) -> void:
	muted = value
	if muted:
		audio.stop()

func reset_presentation() -> void:
	elapsed = 1.0
	pending_contact = false
	flash.visible = false
	audio.stop()
	player.racket.transform = racket_rest
	player.visual.rotation.x = 0.0
	player.visual.rotation.z = 0.0
	stance_yaw = 0.0
	shot_side = "forehand"
	_apply_body(0.0, 0.0)
	_update_arm()

func _exit_tree() -> void:
	if audio != null:
		audio.stop()
