class_name EnemyIdolledSpawner
extends Node2D


@export var _spawn_radius: float = 50.0
@export var _packed_idol: PackedScene
@export var _packed_enemies: Array[PackedScene]

var _idol: EnemyIdolled
var _enemies: Array[Enemy]


func _ready() -> void:
	for i in _enemies.size():
		var inst: Enemy = _enemies[i]
		var x: float = randf_range(-_spawn_radius, _spawn_radius)
		var y: float = sqrt(_spawn_radius * _spawn_radius - x * x)
		inst.position = Vector2(x, y) + position
		get_parent().add_child(inst)
		inst.died.connect(_idol.idol_died.unbind(1), CONNECT_APPEND_SOURCE_OBJECT)
		_idol.enemies[inst] = true
	_idol.position = position
	get_parent().add_child(_idol)
	queue_free()


func connect_death_signal(f: Callable) -> void:
	_idol = _packed_idol.instantiate()
	for pack in _packed_enemies:
		var inst: Enemy = pack.instantiate()
		inst.died.connect(f)
		_enemies.push_back(inst)


func get_enemy_amount() -> int:
	return _packed_enemies.size()
