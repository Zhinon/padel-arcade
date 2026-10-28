class_name PadelPracticeHUD
extends CanvasLayer
var panel: PanelContainer
var status: Label
var counter: Label
var title: Label
var controls: Label
var compact: bool = false
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
	title.text = "PRÁCTICA · GOLPE BASE"
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
	controls.text = "WASD / flechas: mover · Espacio: cargar / soltar fija · R: pelota · T: zona · P: pausa · F8: laboratorio"
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_font_size_override("font_size", 16)
	controls.add_theme_color_override("font_color", Color("d0dde0"))
	column.add_child(controls)
	_resize()
	get_window().size_changed.connect(_resize)

func _resize() -> void:
	compact = get_window().size.x < 800
	if title != null:
		title.text = "PRÁCTICA · P pausa · F8 lab" if compact else "PRÁCTICA · GOLPE BASE"
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
	counter.text = "Contactos: %d" % controller.hits
	status.remove_theme_color_override("font_color")
	if controller.is_preparing():
		var near_ideal: bool = absf(controller.shot_charge - controller.perfect_charge) <= controller.perfect_tolerance
		status.add_theme_color_override("font_color", Color("ddff74") if near_ideal else (Color("ffb38a") if controller.shot_charge > 0.94 else Color("ffffff")))
	if paused:
		status.text = "PAUSA · P para continuar"
	elif controller.charging:
		status.text = ("Carga %d%% · ideal 90%% · direccional apunta" if compact else "Carga %d%% · soltá cerca del 90%% para fijar · direccional apunta") % roundi(100.0 * controller.charge_time / controller.full_preparation)
	elif controller.armed_time > 0.0:
		status.text = "Fijada %d%% · apuntá · Espacio cancela" % roundi(controller.shot_charge * 100.0)
	else:
		status.text = "WASD: mover · R: pelota · Espacio: cargar/fijar" if compact and last_message.begins_with("R para") else last_message
