class_name EnemyIdolledSpawner
extends Node2D


@export var _spawn_radius: float = 80.0
@export var _packed_idol: PackedScene
@export var _packed_enemies: Array[PackedScene]


func _ready() -> void:
	var em := EnemyMother.get_instance()
	var idol: EnemyIdolled = _packed_idol.instantiate()
	idol.position = position
	for pack in _packed_enemies:
		var inst: Enemy = pack.instantiate()
		var x: float = randf_range(-_spawn_radius, _spawn_radius)
		var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
		var pos := Vector2(x, y)
		if (pos + position).distance_squared_to(idol.TARGET) < position.distance_squared_to(idol.TARGET):
			pos = Vector2(-pos.x, -pos.y)
		inst.died.connect(idol.idol_died.unbind(1), CONNECT_APPEND_SOURCE_OBJECT)
		idol.enemies[inst] = true
		em.single_spawn(inst, pos + position)
	em.single_spawn(idol, position)
	queue_free()


func get_enemy_amount() -> int:
	return _packed_enemies.size() + 1
