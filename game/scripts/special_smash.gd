class_name PadelSpecialSmash
extends RefCounted
## Pure launch search. It never moves the real ball or changes collision response.
static func plan(ball: PadelBallSimulation, at: Vector3, kind: String, side: float) -> Dictionary:
	var best: Dictionary = {}
	var score := INF
	var started := Time.get_ticks_usec()
	var ratios: Array = [0.04,0.08,0.12,0.16,0.20,0.24,0.28,0.32,0.36,0.40,0.44,0.48,0.52,0.56] if kind == "x3" else [0.0]
	for horizontal: float in [22.0,26.0,30.0,34.0,38.0,42.0,46.0,50.0]:
		for down: float in [12.0,14.0,16.0,18.0,20.0,22.0,24.0]:
			for ratio: float in ratios:
				var velocity := Vector3(horizontal * ratio * side, -down, -horizontal * sqrt(1.0-ratio*ratio))
				if velocity.length() > ball.max_speed or velocity.length() >= score: continue
				if kind == "x3" and absf(at.x + velocity.x * (-10.0+ball.radius-at.z) / velocity.z) > 4.6: continue
				var result := _trace(ball, at, velocity, kind)
				if result.is_empty(): continue
				var cost: float = velocity.length() + absf(result.exit.y - (3.8 if kind == "x3" else 4.9)) * 4.0
				if cost < score:
					score = cost
					best = result
					best["velocity"] = velocity
	best["search_ms"] = (Time.get_ticks_usec()-started)/1000.0
	return best

static func _trace(ball: PadelBallSimulation, at: Vector3, velocity: Vector3, kind: String) -> Dictionary:
	var dt := 1.0 / Engine.physics_ticks_per_second
	var drag := exp(-ball.air_drag*dt)
	var gravity := ball.gravity_strength
	var radius := ball.radius
	var point := at
	var speed := velocity
	var floor_seen := false
	var glass_seen := false
	var landing := Vector3.ZERO
	for tick in range(300):
		var previous := point
		speed.y -= gravity*dt
		speed *= drag
		point += speed*dt
		if previous.z > 0 and point.z <= 0:
			var net_y := lerpf(previous.y,point.y,previous.z/(previous.z-point.z))
			if net_y < 1.05+radius: return {}
		if point.y <= radius:
			if floor_seen or point.z >= -0.2 or absf(point.x) >= 4.8: return {}
			var fraction := (previous.y-radius)/(previous.y-point.y)
			point = previous.lerp(point,fraction)
			landing = point
			floor_seen = true
			speed = ball.floor_tangent(Vector3(speed.x,0,speed.z),-speed.y)*ball.floor_retention + Vector3.UP*(-speed.y)*ball.floor_bounce
			point += Vector3.UP*0.0002 + speed*dt*(1.0-fraction)
		if point.z <= -10.0+radius and speed.z < 0:
			var fraction := (previous.z-(-10.0+radius))/(previous.z-point.z)
			var crossing := previous.lerp(point,clampf(fraction,0,1))
			if not floor_seen: return {}
			if kind == "x4":
				if crossing.y > 4.0+radius+0.2 and crossing.y < 6.5:
					return {"exit":crossing,"landing":landing,"kind":kind}
				return {}
			if glass_seen or crossing.y >= 3.0-radius-0.12: return {}
			glass_seen = true
			speed = Vector3(speed.x*ball.glass_retention,speed.y*ball.glass_retention,-speed.z*ball.glass_bounce)
			point = crossing + Vector3(0,0,0.0002) + speed*dt*(1.0-clampf(fraction,0,1))
		if absf(point.x) >= 5.0-radius:
			var x_plane := signf(point.x)*(5.0-radius)
			var fraction := (x_plane-previous.x)/(point.x-previous.x)
			var crossing := previous.lerp(point,clampf(fraction,0,1))
			if kind == "x3" and floor_seen and glass_seen and crossing.z > -7.7 and crossing.z < -0.4 and crossing.y > 3.0+radius+0.2 and crossing.y < 5.8:
				return {"exit":crossing,"landing":landing,"kind":kind}
			return {}
	return {}
