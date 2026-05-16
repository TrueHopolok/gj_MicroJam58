class_name EnemyRotate
extends Enemy


@export var _rotation_strength: float = 300.0

var _counter_clockwise: bool = [false, true].pick_random()


func _physics_process(_delta: float) -> void:
	var p: Vector2 = global_position.direction_to(TARGET)
	var d: Vector2 = Vector2(p.y, -p.x) if _counter_clockwise else Vector2(-p.y, p.x)
	velocity = p * speed + d * _rotation_strength

	move_and_slide()

func _process(_delta: float) -> void:
	_sprite.look_at(TARGET)
