class_name Enemy
extends CharacterBody2D


signal died(score: int)

const GROUP: StringName = &"Enemy"
const TARGET := Vector2.ZERO

@export var health: int = 1
@export var speed: float = 40.0
@export var score: int = 2
@export var damage: int = 1

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	velocity = global_position.direction_to(TARGET) * speed
	move_and_slide()


func _process(_delta: float) -> void:
	_sprite.look_at(velocity)


func _ready() -> void:
	_sprite.play()


func _die() -> void:
	queue_free()
	died.emit(score)


func target_reached() -> int:
	queue_free()
	died.emit(0)
	return damage


func connect_death_signal(f: Callable) -> void:
	died.connect(f)


func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	if health <= 0:
		_die()
