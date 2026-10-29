class_name PadelPlayerMotor
extends CharacterBody3D
@export var court_sign: float = 1.0
@export var speed: float = 5.2
@export var acceleration: float = 25.0
@export var preparation_speed_factor: float = 0.0
@export var preparation_brake: float = 60.0
var enabled: bool = false
var grounded: bool = false
var preparing: bool = false
var input_adapter: Node
var visual: Node3D
var racket: MeshInstance3D
var selection_ring: MeshInstance3D
var walk_time: float = 0.0

func _ready() -> void:
	process_physics_priority = -10
	collision_layer = 4
	collision_mask = 1
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	var collider := CollisionShape3D.new()
	collider.shape = capsule
	collider.position.y = 0.9
	add_child(collider)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.37
	ring_mesh.outer_radius = 0.43
	selection_ring = MeshInstance3D.new()
	selection_ring.mesh = ring_mesh
	selection_ring.position.y = 0.025
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("ddff74")
	selection_ring.material_override = material
	selection_ring.visible = false
	add_child(selection_ring)

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	var direction: Vector2 = Vector2.ZERO if input_adapter == null else input_adapter.movement()
	move_player(direction, delta)
	walk_time += delta * Vector2(velocity.x, velocity.z).length()
	if visual != null:
		visual.position.y = 0.015 * sin(walk_time * 12.0) if direction.length() > 0.1 else 0.0
	selection_ring.material_override.albedo_color = Color("ffcf70") if preparing else Color("ddff74")

func move_player(direction: Vector2, delta: float) -> void:
	direction = direction.limit_length(1.0)
	var target_speed := speed * (preparation_speed_factor if preparing else 1.0)
	var horizontal := Vector2(velocity.x, velocity.z).move_toward(direction * target_speed, (preparation_brake if preparing else acceleration) * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.y
	velocity.y = 0.0 if grounded else velocity.y - 9.81 * delta
	var motion := velocity * delta
	for collision_index in range(3):
		if motion.is_zero_approx():
			break
		var collision := move_and_collide(motion)
		if collision == null:
			break
		var normal := collision.get_normal()
		if normal.y > 0.9:
			grounded = true
		velocity = velocity.slide(normal)
		motion = collision.get_remainder().slide(normal)
	var constrained_x := clampf(position.x, -4.6, 4.6)
	var constrained_z := clampf(position.z * court_sign, 0.6, 9.5) * court_sign
	if position.x != constrained_x: velocity.x = 0.0
	if position.z != constrained_z: velocity.z = 0.0
	position.x = constrained_x
	position.z = constrained_z
	if visual != null and direction.length() > 0.1 and not preparing:
		# Small turn: retain a readable stance facing the opposing half.
		visual.rotation.y = lerp_angle(visual.rotation.y, (PI if court_sign < 0 else 0.0) - direction.x * 0.35 * court_sign, minf(delta * 12, 1.0))

func reset_position(at: Vector3) -> void:
	position = at
	velocity = Vector3.ZERO
	grounded = false
	preparing = false
	if visual != null:
		visual.position.y = 0.0
		visual.rotation = Vector3(0, PI if court_sign < 0 else 0.0, 0)
