class_name PadelPracticeInput
extends Node
## Device input -> game actions; movement/shot code has no physical key names.
signal prepare_requested
signal release_requested(aim: Vector2)
signal feed_requested
signal next_lane_requested
signal pause_requested
signal focus_lost
var enabled: bool = false
var paused: bool = false

static func install_actions() -> void:
	var keys := {
		"padel_left": [KEY_A, KEY_LEFT], "padel_right": [KEY_D, KEY_RIGHT],
		"padel_forward": [KEY_W, KEY_UP], "padel_back": [KEY_S, KEY_DOWN],
		"padel_shot": [KEY_SPACE], "padel_feed": [KEY_R],
		"padel_next_lane": [KEY_T], "padel_pause": [KEY_P, KEY_ESCAPE],
	}
	for action: String in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, 0.2)
		for code: int in keys[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(action, key)
	var buttons := {"padel_shot": JOY_BUTTON_A, "padel_feed": JOY_BUTTON_X, "padel_next_lane": JOY_BUTTON_Y, "padel_pause": JOY_BUTTON_START}
	for action: String in buttons:
		var button := InputEventJoypadButton.new()
		button.button_index = buttons[action]
		if not InputMap.action_has_event(action, button):
			InputMap.action_add_event(action, button)
	for action: String in ["padel_left", "padel_right", "padel_forward", "padel_back"]:
		var axis := InputEventJoypadMotion.new()
		axis.axis = JOY_AXIS_LEFT_X if action in ["padel_left", "padel_right"] else JOY_AXIS_LEFT_Y
		axis.axis_value = -1.0 if action in ["padel_left", "padel_forward"] else 1.0
		if not InputMap.action_has_event(action, axis):
			InputMap.action_add_event(action, axis)

func movement() -> Vector2:
	if not enabled or paused:
		return Vector2.ZERO
	return Input.get_vector("padel_left", "padel_right", "padel_forward", "padel_back")

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or (event is InputEventKey and event.echo):
		return
	if event.is_action_pressed("padel_pause"):
		pause_requested.emit()
	elif paused:
		return
	elif event.is_action_pressed("padel_shot"):
		prepare_requested.emit()
	elif event.is_action_released("padel_shot"):
		release_requested.emit(movement())
	elif event.is_action_pressed("padel_feed"):
		feed_requested.emit()
	elif event.is_action_pressed("padel_next_lane"):
		next_lane_requested.emit()
	else:
		return
	get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT and enabled and not paused:
		focus_lost.emit()
