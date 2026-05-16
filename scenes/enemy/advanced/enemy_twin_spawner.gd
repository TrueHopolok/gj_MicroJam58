class_name EnemyTwinSpawner
extends Node2D


@export var _twin_1: PackedScene
@export var _twin_2: PackedScene
@export var _spawn_radius: float = 20.0
@onready var _inst_1: EnemyTwin = _twin_1.instantiate()
@onready var _inst_2: EnemyTwin = _twin_2.instantiate()

func _ready() -> void:
	var x: float = randf_range(0, _spawn_radius)
	var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
	_inst_1.position = Vector2(x, y) + position
	_inst_2.position = Vector2(-x, -y) + position
	_inst_1.twin = _inst_2
	_inst_2.twin = _inst_1
	get_parent().add_child.call_deferred(_inst_1)
	get_parent().add_child.call_deferred(_inst_2)
	queue_free()


func connect_death_signal(f: Callable) -> void:
	_twin_1.died.connect(f)
	_twin_2.died.connect(f)


func get_enemy_amount() -> int:
	return 2
