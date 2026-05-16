class_name EnemyTwinSpawner
extends Node2D


@export var _twin_1: PackedScene
@export var _twin_2: PackedScene
@export var _spawn_radius: float = 20.0

var _inst_1: EnemyTwin
var _inst_2: EnemyTwin


func _ready() -> void:
	var x: float = randf_range(0, _spawn_radius)
	var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
	_inst_1.position = Vector2(x, y) + position
	_inst_2.position = Vector2(-x, -y) + position
	_inst_1.twin = _inst_2
	_inst_2.twin = _inst_1
	get_parent().add_child(_inst_1)
	get_parent().add_child(_inst_2)
	queue_free()


func connect_death_signal(f: Callable) -> void:
	_inst_1 = _twin_1.instantiate()
	_inst_2 = _twin_2.instantiate()
	_inst_1.died.connect(f)
	_inst_2.died.connect(f)


func get_enemy_amount() -> int:
	return 2
