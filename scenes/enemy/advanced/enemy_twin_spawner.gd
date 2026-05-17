class_name EnemyTwinSpawner
extends Node2D


@export var _twin_1: PackedScene
@export var _twin_2: PackedScene
@export var _spawn_radius: float = 20.0


func _ready() -> void:
	var inst_1: EnemyTwin = _twin_1.instantiate()
	var inst_2: EnemyTwin = _twin_2.instantiate()
	var x: float = randf_range(0, _spawn_radius)
	var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
	inst_1.position = Vector2(x, y) + position
	inst_2.position = Vector2(-x, -y) + position
	inst_1.twin = inst_2
	inst_2.twin = inst_1
	get_parent().add_child(inst_1)
	get_parent().add_child(inst_2)
	queue_free()


func get_enemy_amount() -> int:
	return 2
