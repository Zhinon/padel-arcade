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
var arm_rest: Transform3D
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
	for child in player.visual.get_children():
		if child is MeshInstance3D and child.name.begins_with("Arm") and child.position.x > 0.0:
			arm = child
			arm_rest = arm.transform
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
	follow_side = 1.0 if event.position.x >= player.position.x else -1.0
	player.visual.rotation.x = -0.08 if last_kind != "defense" else 0.06
	player.visual.rotation.z = -follow_side * (0.12 if last_kind == "perfect" else 0.06)
	contact_local = player.visual.to_local(event.position)
	# Contact pose is applied in the same callback as the physical strike.
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
		var follow := Vector3(-follow_side * (0.65 if last_kind == "perfect" else 0.4), 1.0, -0.35)
		player.racket.position = contact_local.lerp(follow, smoothstep(0.0, 0.45, t)).lerp(racket_rest.origin, smoothstep(0.45, 1.0, t))
		player.racket.rotation.y = follow_side * sin(t * PI) * 0.8
		player.visual.rotation.x *= maxf(0.0, 1.0 - delta * 15.0)
		player.visual.rotation.z *= maxf(0.0, 1.0 - delta * 15.0)
		player.selection_ring.material_override.albedo_color = _color()
	elif player.preparing:
		var side := 1.0 if controller.ball.position.x >= player.position.x else -1.0
		var charge: float = controller.shot_charge
		var windup := Vector3(side * (0.45 + charge * 0.12), 0.95 + charge * 0.12, 0.15 + charge * 0.25)
		player.racket.position = player.racket.position.lerp(windup, minf(delta * 18.0, 1.0))
		player.racket.rotation = Vector3(0, -side * 0.7, side * 0.15)
		player.visual.rotation.z = lerpf(player.visual.rotation.z, -side * 0.08, minf(delta * 14.0, 1.0))
	else:
		player.racket.transform = racket_rest
		player.visual.rotation.x = 0.0
		player.visual.rotation.z = 0.0
	_update_arm()
	flash.visible = elapsed < flash_duration
	if flash.visible:
		var progress := elapsed / flash_duration
		flash.scale = Vector3.ONE * lerpf(1.0, 2.2, progress)
		var color := _color()
		color.a = 1.0 - progress
		flash_material.albedo_color = color

func _update_arm() -> void:
	if arm == null:
		return
	var shoulder := Vector3(0.27, 1.38, 0.0)
	var hand: Vector3 = player.racket.position + Vector3(0, -0.14, 0)
	var offset: Vector3 = hand - shoulder
	arm.position = (shoulder + hand) * 0.5
	if offset.length() > 0.01:
		arm.quaternion = Quaternion(Vector3.UP, offset.normalized())
		arm.scale = Vector3(1, offset.length() / 0.68, 1)

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
	if arm != null:
		arm.transform = arm_rest

func _exit_tree() -> void:
	if audio != null:
		audio.stop()
