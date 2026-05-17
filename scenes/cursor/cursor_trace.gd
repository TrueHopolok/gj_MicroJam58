class_name CursorTrace
extends Node2D


const START_OPACITY: float = 0.4
const LIFETIME: float = 0.4


@onready var circle: Circle = $Circle


func _ready() -> void:
	var t := create_tween()
	t.tween_property(circle, ^"color:a", 0.0, LIFETIME).from(START_OPACITY)
	t.chain().tween_callback(self.queue_free)


func set_radius(r: float):
	circle.radius = r
