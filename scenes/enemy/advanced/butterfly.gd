class_name Butterfly
extends Enemy


@export var heal: int = 10


func _die() -> void:
	super()
	Castle.get_instance().take_damage(damage)


func target_reached() -> int:
	queue_free()
	died.emit(score)
	return -heal
