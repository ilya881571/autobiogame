extends CharacterBody2D

# Скорость игрока, чтобы он ходил плавно
const SPEED = 100.0

@onready var interaction_radius: Area2D = $InteractionRadius

# ПУТИ ДЛЯ ДИАЛОГОВ (Вернули ../ так как они лежат на сцене комнаты)
@onready var ui_label: Label = get_node("../CanvasLayer/VBoxContainer/Label")
@onready var choice_menu: HBoxContainer = get_node("../CanvasLayer/VBoxContainer/HBoxContainer")
@onready var btn_true: Button = get_node("../CanvasLayer/VBoxContainer/HBoxContainer/True")
@onready var btn_false: Button = get_node("../CanvasLayer/VBoxContainer/HBoxContainer/Falce")

# ПУТИ ДЛЯ МОБИЛЬНОГО UI (Оставили внутренними, так как они внутри игрока)
@onready var virtual_joystick: Control = get_node_or_null("CanvasLayer/VirtualJoystick")
@onready var e_button_container: MarginContainer = get_node_or_null("CanvasLayer/MarginContainer")

var is_reading: bool = false
var current_pages: Array = []
var current_page_index: int = 0

# Настройки для выбора
var has_choice: bool = false
var choice_at_page: int = -1
var text_true: String = "Да"
var text_false: String = "Нет"
var is_choosing: bool = false

func _ready() -> void:
	# Отключаем дефолтный фокус кнопок от мышки, чтобы она не мешала нашей клавиатуре
	if btn_true:
		btn_true.focus_mode = Control.FOCUS_ALL
	if btn_false:
		btn_false.focus_mode = Control.FOCUS_ALL
	
	# Подключаем сигналы нажатий кнопок (для мышки или тапа по экрану)
	if btn_true and not btn_true.pressed.is_connected(_on_take_pressed):
		btn_true.pressed.connect(_on_take_pressed)
	if btn_false and not btn_false.pressed.is_connected(_on_leave_pressed):
		btn_false.pressed.connect(_on_leave_pressed)
	
	# Если у устройства нет тачскрина (это ПК) — намертво прячем мобильное управление
	if not DisplayServer.is_touchscreen_available():
		if virtual_joystick:
			virtual_joystick.hide()
		if e_button_container:
			e_button_container.hide()

func _physics_process(_delta: float) -> void:
	# Во время чтения или выбора игрок не должен ходить
	if is_reading or is_choosing:
		velocity = Vector2.ZERO
		return
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# 1. ЛОГИКА УПРАВЛЕНИЯ В МЕНЮ ВЫБОРА
	if is_choosing:
		if event.is_action_pressed("move_right"):
			if btn_false: btn_false.grab_focus()
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_pressed("move_left"):
			if btn_true: btn_true.grab_focus()
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_pressed("Action"):
			if choice_menu:
				var focused_btn = choice_menu.get_viewport().gui_get_focus_owner()
				if focused_btn is Button:
					focused_btn.emit_signal("pressed")
			get_viewport().set_input_as_handled()
			return

	# 2. ОБЫЧНАЯ ЛОГИКА ЛИСТАНИЯ ДИАЛОГОВ
	if event.is_action_pressed("Action"):
		handle_action_trigger()

# Функция действия (листание / запуск)
func handle_action_trigger() -> void:
	if is_reading:
		current_page_index += 1
		
		# Нужны ли кнопки прямо на этом слайде?
		if has_choice and current_page_index == choice_at_page:
			if current_page_index < current_pages.size():
				if ui_label: ui_label.text = current_pages[current_page_index]
				show_choice()
				return
		
		if current_page_index < current_pages.size():
			if ui_label: ui_label.text = current_pages[current_page_index]
		else:
			close_dialogue()
		return
		
	# СТАРТ ДИАЛОГА
	if interaction_radius:
		var overlapping_areas = interaction_radius.get_overlapping_areas()
		for area in overlapping_areas:
			var parent_node = area.get_parent()
			if parent_node and parent_node.has_method("interact"):
				var dialogue_data = parent_node.interact()
				
				# Если это СТОЛ (вернул Словарь)
				if dialogue_data is Dictionary:
					current_pages = dialogue_data.get("pages", [])
					has_choice = dialogue_data.get("has_choice", false)
					choice_at_page = dialogue_data.get("choice_at_page", -1)
					text_true = dialogue_data.get("text_true", "Взять")
					text_false = dialogue_data.get("text_false", "Оставить")
					
					start_reading()
					break
					
				# Если это ДИВАН, ШКАФ или КРЕСЛО (вернули Массив)
				elif dialogue_data is Array and dialogue_data.size() > 0:
					current_pages = dialogue_data
					has_choice = false
					choice_at_page = -1
					
					start_reading()
					break

func start_reading() -> void:
	if current_pages.size() > 0:
		current_page_index = 0
		if ui_label:
			ui_label.text = current_pages[current_page_index]
			ui_label.visible = true
		is_reading = true
		velocity = Vector2.ZERO

func show_choice() -> void:
	is_choosing = true
	
	if btn_true and btn_false and choice_menu:
		btn_true.custom_minimum_size = Vector2(100, 40)
		btn_false.custom_minimum_size = Vector2(100, 40)
		btn_true.text = text_true
		btn_false.text = text_false
		
		choice_menu.visible = true
		btn_true.visible = true
		btn_false.visible = true
		
		btn_true.grab_focus()

func _on_take_pressed() -> void:
	hide_choice_ui()
	current_page_index = 3
	if current_page_index < current_pages.size():
		if ui_label: ui_label.text = current_pages[current_page_index]
	else:
		close_dialogue()

func _on_leave_pressed() -> void:
	hide_choice_ui()
	close_dialogue()

func hide_choice_ui() -> void:
	is_choosing = false
	if choice_menu: choice_menu.visible = false
	if btn_true: btn_true.visible = false
	if btn_false: btn_false.visible = false

func close_dialogue() -> void:
	hide_choice_ui()
	if ui_label:
		ui_label.text = ""
		ui_label.visible = false
	is_reading = false
	current_pages = []
	current_page_index = 0
	has_choice = false
	choice_at_page = -1

# Сигнал от экранной TextureButton
func _on_ebutton_pressed() -> void:
	handle_action_trigger()
