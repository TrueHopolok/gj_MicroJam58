class_name EnemyIdolledSpawner
extends Node2D


@export var _spawn_radius: float = 50.0
@export var _packed_idol: PackedScene
@export var _packed_enemies: Array[PackedScene]


func _ready() -> void:
	var idol: EnemyIdolled = _packed_idol.instantiate()
	idol.position = position
	for pack in _packed_enemies:
		var inst: Enemy = pack.instantiate()
		var x: float = randf_range(-_spawn_radius, _spawn_radius)
		var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
		inst.position = Vector2(x, y) + position
		inst.died.connect(idol.idol_died.unbind(1), CONNECT_APPEND_SOURCE_OBJECT)
		idol.enemies[inst] = true
		get_parent().add_child(inst)
	get_parent().add_child(idol)
	queue_free()


func get_enemy_amount() -> int:
	return _packed_enemies.size()
