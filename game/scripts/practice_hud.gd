class_name PadelPracticeHUD
extends CanvasLayer
var panel: PanelContainer
var status: Label
var counter: Label
var title: Label
var controls: Label
var compact: bool = false
var impact_feedback: Node
var controller: Node
var paused: bool = false
var last_message: String = "R para recibir una pelota · el jugador marcado es tuyo"

func _ready() -> void:
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 16
	panel.offset_top = 12
	panel.offset_right = -16
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.075, 0.09, 0.94)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	title = Label.new()
	title.text = "PRÁCTICA · PLANO / GLOBO"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("ddff74"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	counter = Label.new()
	counter.add_theme_font_size_override("font_size", 16)
	top.add_child(counter)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 18)
	column.add_child(status)
	controls = Label.new()
	controls.text = "WASD / flechas: mover y apuntar · Espacio: plano · E: globo · soltar fija · R: pelota · T: zona · P: pausa · M: audio · F8: laboratorio"
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_font_size_override("font_size", 16)
	controls.add_theme_color_override("font_color", Color("d0dde0"))
	column.add_child(controls)
	_resize()
	get_window().size_changed.connect(_resize)

func _resize() -> void:
	compact = get_window().size.x < 800
	if title != null:
		title.text = "Espacio: plano · E: globo · P: pausa" if compact else "PRÁCTICA · PLANO / GLOBO"
		title.add_theme_font_size_override("font_size", 16 if compact else 18)
		status.add_theme_font_size_override("font_size", 16 if compact else 18)
		controls.visible = not compact
	# Logical pixels follow window pixels for legible labels when resized.
	if get_window().content_scale_size != get_window().size:
		get_window().set_deferred("content_scale_size", get_window().size)

func show_feedback(message: String) -> void:
	last_message = message

func _process(_delta: float) -> void:
	if not visible or controller == null:
		return
	counter.text = "Contactos: %d%s" % [controller.hits, " · sin audio" if impact_feedback != null and impact_feedback.muted else ""]
	status.remove_theme_color_override("font_color")
	if controller.is_preparing():
		var near_ideal: bool = absf(controller.shot_charge - controller.perfect_charge) <= controller.perfect_tolerance
		status.add_theme_color_override("font_color", Color("ddff74") if near_ideal else (Color("ffb38a") if controller.shot_charge > 0.94 else Color("ffffff")))
	if paused:
		status.text = "PAUSA · P para continuar"
	elif controller.charging:
		if controller.shot_kind == controller.ShotType.LOB:
			status.text = "Globo %d%% · soltar fija altura y profundidad" % roundi(controller.shot_charge * 100.0)
		else:
			status.text = ("Plano %d%% · suave + abajo: chiquita" if compact else "Plano %d%% · suave + abajo: chiquita · 90%%: golpe potente · soltar fija") % roundi(100.0 * controller.charge_time / controller.full_preparation)
	elif controller.armed_time > 0.0:
		if controller.shot_kind == controller.ShotType.LOB:
			status.text = "Globo fijado %d%% · apuntá · E cancela" % roundi(controller.shot_charge * 100.0)
		else:
			var short_hint: String = " · abajo: chiquita" if controller.shot_charge <= controller.touch_charge_limit else ""
			status.text = "Plano fijado %d%%%s · apuntá · Espacio cancela" % [roundi(controller.shot_charge * 100.0), short_hint]
	else:
		status.text = "WASD: mover · R: pelota · Espacio: cargar/fijar" if compact and last_message.begins_with("R para") else last_message
