extends Control

# Ссылка на панель патчноута (ColorRect)
@onready var patch_note_rect: ColorRect = $ColorRect

# Ссылка на кнопку выхода
@onready var quit_button: Button = $VBoxContainer/QuitButton

# Ссылка на твой лейбл версии на сцене главного меню
@onready var version_label: Label = $Label

func _ready() -> void:
	# Скрываем патчноут при старте
	if patch_note_rect:
		patch_note_rect.visible = false
		
	# Выводим версию проекта в лейбл на главном экране
	var project_version = ProjectSettings.get_setting("application/config/version")
	if version_label:
		if project_version:
			version_label.text = "v" + str(project_version)
		else:
			version_label.text = "v1.0-alpha"
		
	# Проверяем, запущена ли игра на мобильном телефоне (Android или iOS)
	if OS.has_feature("mobile"):
		if quit_button:
			quit_button.queue_free() # Полностью удаляем кнопку из меню на телефонах


# Кнопка "Играть"
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Сцены/room.tscn")

# Кнопка "Выход"
func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Кнопка "Патчноут" (Открывает окно)
func _on_patch_note_button_pressed() -> void:
	if patch_note_rect:
		patch_note_rect.visible = true

# Кнопка "Назад" внутри патчноута (Закрывает окно)
func _on_back_button_pressed() -> void:
	if patch_note_rect:
		patch_note_rect.visible = false
