class_name EnemyTwinSpawner
extends Node2D


@export var _twin_1: PackedScene
@export var _twin_2: PackedScene


func _ready() -> void:
	var inst_1: EnemyTwin = _twin_1.instantiate()
	var inst_2: EnemyTwin = _twin_2.instantiate()
	inst_1.twin = inst_2
	inst_2.twin = inst_1

	var dist := global_position.length()

	EnemyMother.get_instance().single_spawn(inst_1, Vector2.from_angle(randf_range(0, TAU)) * dist)
	EnemyMother.get_instance().single_spawn(inst_2, Vector2.from_angle(randf_range(0, TAU)) * dist)

	queue_free()


func get_enemy_amount() -> int:
	return 2
