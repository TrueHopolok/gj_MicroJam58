extends AnimatedSprite2D


func _ready() -> void:
	visibility_changed.connect(_randomize_sprite)
	_randomize_sprite()


func _randomize_sprite() -> void:
	frame = randi_range(0, sprite_frames.get_frame_count("default"))
