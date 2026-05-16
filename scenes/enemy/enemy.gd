class_name Enemy
extends CharacterBody2D


signal died(score: int)

const GROUP: StringName = &"Enemy"
const TARGET: Vector2 = Vector2(320, 180)

@export var health: int = 1
@export var speed: float = 40.0
@export var score: int = 2


func _physics_process(_delta: float) -> void:
	velocity = global_position.direction_to(TARGET) * speed
	move_and_slide()


func _die() -> void:
	died.emit(score)
	queue_free()


func connect_death_signal(f: Callable) -> void:
	died.connect(f)


func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	if health <= 0:
		_die()
