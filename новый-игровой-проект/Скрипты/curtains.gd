extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_open: bool = false

# Игрок сам вызовет эту функцию, когда нажмет E внутри радиуса!
func interact() -> void:
	if not is_open:
		is_open = true
		animated_sprite.play("Open")
	else:
		is_open = false
		animated_sprite.play("Close")
