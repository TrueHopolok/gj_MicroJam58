class_name EnemyIdolledSpawner
extends Node2D


@export var _spawn_radius: float = 50.0
@export var _packed_idol: PackedScene
@export var _packed_enemies: Array[PackedScene]

var _enemies: Array[Enemy]
var _instanced: bool = false


func _ready() -> void:
	instansiate_all_enemies()
	queue_free()


func instansiate_all_enemies() -> void:
	if _instanced:
		return
	_instanced = true

	var idol: EnemyIdolled = _packed_idol.instantiate()
	idol.position = position
	get_parent().add_child.call_deferred(idol)

	for pack in _packed_enemies:
		var inst: Enemy = pack.instantiate()
		var x: float = randf_range(-_spawn_radius, _spawn_radius)
		var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
		inst.position = Vector2(x, y) + position
		get_parent().add_child.call_deferred(inst)

		_enemies.push_back(inst)
		idol.enemies[inst] = true


func connect_death_signal(f: Callable) -> void:
	if !_instanced:
		instansiate_all_enemies()
	for enemy in _enemies:
		enemy.died.connect(f)


func get_enemy_amount() -> int:
	return _packed_enemies.size()
