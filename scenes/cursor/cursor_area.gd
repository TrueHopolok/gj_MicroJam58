class_name CursorArea
extends Node2D


@export var sprite: Sprite2D


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	position = mouse_pos

 
func set_radius(r: float) -> void:
	sprite.scale = Vector2.ONE * ((r * 2) / sprite.texture.get_size().x)
