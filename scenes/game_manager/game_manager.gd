class_name GameManager
extends Node


@export var spawn_policy: SpawnPolicy
@export var cursor_manager: CursorManager
@export var castle: Castle

var _event_queue: Array[TimedEvent] = []
var _active_enemies: int = 0
var _level_counter: int = -1 # first level is 0 not 1

const MAX_BIG_SPAWNS: int = 5
const BIG_SPAWN_COST: int = 10

## how much of the budget goes towards big waves
const BIG_SPAWN_PERCENT: int = 40

const CURSOR_RADIUS_BIG: float = 64
const CURSOR_RADIUS_SMALL: float = 2

const GAME_OVER_SCENE: StringName = &"res://ui/menus/gameover_menu/gameover_menu.tscn"
const GROUP_NAME: StringName = &"GameManager"


static func find() -> GameManager:
	var node := (Engine.get_main_loop() as SceneTree).get_first_node_in_group(GROUP_NAME) as GameManager
	if not is_instance_valid(node):
		push_error("GameManager.find(): no game manager instance found")
		return null
	return node


func _ready() -> void:
	add_to_group(GROUP_NAME)

	Persistence.current_score = 0

	randomize()

	if spawn_policy == null:
		push_error("game manager: no spawn policy")
		return

	if castle == null:
		push_error("game manager: no castle")
		return

	if cursor_manager == null:
		push_error("game manager: no cursor manager")
		return

	spawn_policy.initialize()

	_next_level()

	castle.game_over.connect(_on_game_over)


func _physics_process(_delta: float) -> void:
	var now := Time.get_ticks_usec()

	while not _event_queue.is_empty() and _event_queue.back().t <= now:
		_process_event(_event_queue.pop_back())
		_try_finish_level()


func _clamp_remap(v: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
	return remap(clampf(v, istart, istop), istart, istop, ostart, ostop)


func _process_event(ev: TimedEvent) -> void:
	print("Process event %s" % ev)

	var m: EnemyMother = EnemyMother.get_instance()
	if ev.spawn != null:
		var inst: Node2D = ev.spawn.instantiate()
		m.single_spawn(inst)

	if not ev.tide.is_empty():
		var insts: Array[Node2D] = []

		for p: PackedScene in ev.tide:
			var inst: Node2D = p.instantiate()
			insts.push_back(inst)

		m.tide_spawn(insts)


func _on_enemy_death(enemy_score: int = 1) -> void:
	_active_enemies -= 1
	Persistence.current_score += enemy_score

	_try_finish_level()


func _try_finish_level() -> void:
	if _active_enemies > 0 or not _event_queue.is_empty():
		return

	_next_level()


func _next_level() -> void:
	_level_counter += 1
	print("Starting level %d" % _level_counter)

	var spec := spawn_policy.sample(_level_counter)

	print("Generated spec: enemies=%d @ %fHz tides=%d @ %fHz" % [
		spec.enemies.size(),1/spec.enemy_spawn_interval, spec.tides.size(), 1/spec.tide_spawn_interval])

	_execute_level_spec(spec)


func _execute_level_spec(spec: SpawnPolicy.Sample) -> void:
	var start := Time.get_ticks_usec() + 1000000 # in 1 sec

	for i: int in spec.enemies.size():
		var delay: int = roundi(spec.enemy_spawn_interval * 1e6) * (i + 1)
		_event_queue.push_back(TimedEvent.single(start+delay, spec.enemies[i]))
		_queued_enemies += 1

	for i: int in spec.tides.size():
		var delay: int = roundi(spec.tide_spawn_interval * 1e6) * (i + 1)
		_event_queue.push_back(TimedEvent.many(start+delay, spec.tides[i]))
		_queued_enemies += spec.tides[i].size()

	_event_queue.sort_custom(func (lhs: TimedEvent, rhs: TimedEvent) -> bool:
		return lhs.t > rhs.t)

	print(_event_queue)

	var dur := 1 + maxf(spec.enemy_spawn_interval * spec.enemies.size(), spec.tide_spawn_interval * spec.tides.size())
	dur *= spec.cursor_shrink_fract
	create_tween().tween_method(cursor_manager.set_radius, spec.cursor_start, spec.cursor_end, dur)


func _on_game_over() -> void:
	Persistence.submit()
	Transition.change_scene_path(GAME_OVER_SCENE)


func register_enemy(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_death, CONNECT_ONE_SHOT)

	if enemy.has_method("get_enemy_amount"):
		_active_enemies += enemy.get_enemy_amount()
	else:
		_active_enemies += 1


class LevelSpec:
	var enemies: Array[EnemySpec] = []
	var tides: Array[Array] = [] # Array[Array[EnemySpec]]


class TimedEvent:
	var t: int
	var spawn: PackedScene
	var tide: Array[PackedScene]

	static func single(time: int, v: PackedScene) -> TimedEvent:
		var te := TimedEvent.new()
		te.t = time
		te.spawn = v
		return te

	static func many(time: int, v: Array[PackedScene]) -> TimedEvent:
		var te := TimedEvent.new()
		te.t = time
		te.tide =  v
		return te


	func _to_string() -> String:
		var dur := t - Time.get_ticks_usec()
		return "TimedEvent(single=%s, tide=%s, in=%ss)" % [spawn != null, tide.size(), dur * 0.000001]
