@tool
class_name Circle
extends Node2D


@export var filled: bool = false:
	set(v):
		filled = v
		queue_redraw()
@export var border: float = 1.0:
	set(v):
		border = v
		queue_redraw()
@export var color := Color.WHITE:
	set(v):
		color = v
		queue_redraw()
@export var radius: float = 100.0:
	set(v):
		radius = v
		queue_redraw()


func _draw() -> void:
	if filled:
		draw_circle(Vector2.ZERO, radius, color, true)
	else:
		draw_circle(Vector2.ZERO, radius, color, false, border)
