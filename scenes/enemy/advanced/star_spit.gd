extends Sprite2D


const DIST: float = 10.0

@export var speed: float = 100.0

var target: Node2D


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	look_at(target.global_position)
	global_position = global_position.move_toward(target.global_position, delta * speed)

	if global_position.distance_squared_to(target.global_position) <= DIST*DIST:
		queue_free()
