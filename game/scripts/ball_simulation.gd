class_name PadelBallSimulation
extends CharacterBody3D
## Controlled ball integration with swept motion; no rules or rendering authority.

signal contacted(event: Dictionary)
signal stepped
signal launched

@export var radius: float = 0.105 # Deliberately enlarged prototype radius, same as visual.
@export var gravity_strength: float = 9.81
@export var air_drag: float = 0.04
@export var max_speed: float = 60.0
@export var floor_bounce: float = 0.73
@export var glass_bounce: float = 0.68
@export var glass_retention: float = 0.90
@export var fence_bounce: float = 0.48
@export var fence_retention: float = 0.82
@export var fence_yaw_degrees: float = 22.0
@export var fence_pitch_degrees: float = 16.0
@export var fence_seed: int = 42
var fence_rng := RandomNumberGenerator.new()
@export var net_bounce: float = 0.12
@export var floor_retention: float = 0.94
@export var rolling_drag: float = 1.8
@export var max_impacts_per_step: int = 8
var active: bool = true
var elapsed: float = 0.0
var grounded: bool = false
var contacts: Array[Dictionary] = []
var impact_limit_count: int = 0
var last_hitter: int = -1 # No players striking yet.

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := SphereShape3D.new()
	shape.radius = radius
	var collider := CollisionShape3D.new()
	collider.shape = shape
	add_child(collider)

func launch(at: Vector3, initial_velocity: Vector3, seed_override: int = -1) -> void:
	fence_rng.seed = fence_seed if seed_override < 0 else seed_override
	position = at
	velocity = initial_velocity.limit_length(max_speed)
	elapsed = 0.0
	grounded = false
	contacts.clear()
	impact_limit_count = 0
	active = true
	launched.emit()

func _physics_process(delta: float) -> void:
	if active:
		step(delta)

func step(delta: float) -> void:
	if grounded and (absf(position.x) > 5.0 or absf(position.z) > 10.0):
		grounded = false
	if grounded:
		velocity *= exp(-rolling_drag * delta)
		if velocity.length() < 0.03:
			velocity = Vector3.ZERO
	else:
		velocity.y -= gravity_strength * delta
		velocity *= exp(-air_drag * delta)
	velocity = velocity.limit_length(max_speed)
	var remaining := delta
	var used := 0.0
	var impacts := 0
	while remaining > 0.000001 and velocity.length_squared() > 0.000001:
		var motion := velocity * remaining
		var collision := move_and_collide(motion, false, 0.0001)
		if collision == null:
			break
		var fraction := clampf(collision.get_travel().length() / motion.length(), 0.0, 1.0)
		used += remaining * fraction
		remaining *= 1.0 - fraction
		var normal := collision.get_normal()
		var incoming := velocity
		var approach := -incoming.dot(normal)
		var surface := str(collision.get_collider().get_meta("surface", "unknown"))
		if approach > 0.001:
			var restitution := _restitution(surface)
			var tangent := incoming - incoming.dot(normal) * normal
			var retention := floor_retention if surface == "floor" else 0.98
			if surface == "glass":
				retention = glass_retention
			elif surface == "fence":
				retention = fence_retention
			elif surface == "net":
				retention = 0.65
			velocity = tangent * retention + normal * approach * restitution
			var deflection := Vector2.ZERO
			if surface == "fence":
				deflection = Vector2(fence_rng.randf_range(-fence_yaw_degrees, fence_yaw_degrees), fence_rng.randf_range(-fence_pitch_degrees, fence_pitch_degrees))
				velocity = _deflect_fence(velocity, normal, deflection)
			# Below this speed, settle instead of emitting endless floor micro-bounces.
			if surface == "floor" and approach < 0.8 and normal.y > 0.9:
				velocity.y = 0.0
				grounded = true
			var event := {
				"sequence": contacts.size() + 1,
				"time": elapsed + used,
				"surface": surface,
				"collider": str(collision.get_collider().name),
				"position": collision.get_position(),
				"normal": normal,
				"incoming": incoming,
				"outgoing": velocity,
				"side": -1 if collision.get_position().z < 0.0 else 1,
				"last_hitter": last_hitter,
				"fence_deflection_degrees": deflection,
				"fence_seed": fence_rng.seed,
			}
			contacts.append(event)
			contacted.emit(event)
		# Separation is geometric only and must never teleport through the surface.
		position += normal * 0.0002
		impacts += 1
		if impacts >= max_impacts_per_step:
			impact_limit_count += 1
			break # Drop remaining time conservatively; do not tunnel.
	elapsed += delta
	stepped.emit()

func _restitution(surface: String) -> float:
	match surface:
		"floor": return floor_bounce
		"glass": return glass_bounce
		"fence": return fence_bounce
		"net": return net_bounce
	return 0.0


func _deflect_fence(reflected: Vector3, normal: Vector3, angles: Vector2) -> Vector3:
	# Rotate the damped reflection, without creating energy or pointing through mesh.
	var speed := reflected.length()
	if speed < 0.00001:
		return reflected
	var direction := reflected.normalized().rotated(Vector3.UP, deg_to_rad(angles.x))
	var pitch_axis := normal.cross(Vector3.UP).normalized()
	if not pitch_axis.is_zero_approx():
		direction = direction.rotated(pitch_axis, deg_to_rad(angles.y))
	var inward := direction.dot(normal)
	if inward < 0.1:
		direction = (direction - normal * inward + normal * 0.1).normalized()
	return direction * speed
