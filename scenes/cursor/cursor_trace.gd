extends Node2D

class_name CursorTrace


const START_OPACITY: float = 0.75
const LIFETIME: float = 0.5

@export var sprite: Sprite2D


func _ready() -> void:
	var t := create_tween()
	t.tween_property(sprite, ^"modulate:a", 0.0, LIFETIME).from(START_OPACITY)
	t.chain().tween_callback(self.queue_free)

func set_radius(r: float):
	sprite.scale = Vector2.ONE * ((r * 2) / sprite.texture.get_size().x)
