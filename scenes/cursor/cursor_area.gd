class_name CursorArea
extends Node2D


@onready var circle: Circle = $Circle
@onready var circle2: Circle = $Circle2


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	position = mouse_pos


func set_radius(r: float) -> void:
	circle.radius = r
	circle2.radius = r
