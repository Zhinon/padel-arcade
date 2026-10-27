class_name PadelLaunchScenarios
extends RefCounted
## Explicit initial conditions in meters and meters/second. No randomness.

static func all() -> Array[Dictionary]:
	return [
		{"name": "Caída vertical", "position": Vector3(0, 3, 5), "velocity": Vector3.ZERO},
		{"name": "Piso y vidrio de fondo", "position": Vector3(1, 1.6, 4), "velocity": Vector3(1, 2, -13)},
		{"name": "Reja lateral", "position": Vector3(0, 1.4, -2), "velocity": Vector3(11, 2, 0)},
		{"name": "Red", "position": Vector3(0, 0.55, 4), "velocity": Vector3(0, 0, -14)},
		{"name": "Esquina de vidrio", "position": Vector3(3.5, 1.8, 8.5), "velocity": Vector3(10, 1, 10)},
		{"name": "Tiro rápido 60 m/s", "position": Vector3(0, 1.5, -4), "velocity": Vector3(60, 0, 0)},
		{"name": "Globo", "position": Vector3(0, 1.4, 7), "velocity": Vector3(1.5, 10, -9)},
	]
