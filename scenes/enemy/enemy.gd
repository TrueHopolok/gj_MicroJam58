class_name Enemy
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal died(score: int)

const GROUP: StringName = &"Enemy"
const TARGET := Vector2.ZERO

var direction: Vector2 = global_position.direction_to(TARGET)

@export var health: int = 1
@export var speed: float = 40.0
@export var score: int = 2


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func _ready() -> void:
	sprite.play()
	rotate(global_position.angle_to_point(direction))

func _die() -> void:
	died.emit(score)
	queue_free()


func target_reached() -> void:
	died.emit(0)
	queue_free()


func connect_death_signal(f: Callable) -> void:
	died.connect(f)


func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	if health <= 0:
		_die()
