class_name EnemyRotate
extends Enemy


const TOO_FAR_AWAY = 180.0 * 180.0

@export var _rotation_strength: float = 150.0

var _counter_clockwise: bool = [false, true].pick_random()


func _physics_process(_delta: float) -> void:
	var p: Vector2 = global_position.direction_to(TARGET)
	var d: Vector2 = Vector2(p.y, -p.x) if _counter_clockwise else Vector2(-p.y, p.x)
	if TARGET.distance_squared_to(position) > TOO_FAR_AWAY:
		velocity = p * speed * 3
	else:
		velocity = p * speed + d * _rotation_strength
	move_and_slide()
	look_at(velocity)


func _process(_delta: float) -> void:
	_sprite.look_at(TARGET)
