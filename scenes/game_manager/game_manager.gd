class_name GameManager
extends Node


@export var enemies: Array[EnemySpec] = []
@export var cursor_manager: CursorManager
@export var castle: Castle

var _total_enemy_cost: int = 0

var _event_queue: Array[TimedEvent] = []
var _active_enemies: int = 0
var _level_counter: int = 0 # first level is 1 not 0
var _level_start_ticks: int = 0
var _score: int = 0

const LEVEL_TIME: float = 120.0
const MAX_BIG_SPAWNS: int = 5
const BIG_SPAWN_COST: int = 10

## how much of the budget goes towards big waves
const BIG_SPAWN_PERCENT: int = 40

const CURSOR_RADIUS_BIG: float = 64
const CURSOR_RADIUS_SMALL: float = 2

const GAME_OVER_SCENE := preload('uid://bwtp0mt7tkcx4')


func _ready() -> void:
	randomize()

	enemies.sort_custom(func(lhs: EnemySpec, rhs: EnemySpec) -> bool:
		return lhs.cost < rhs.cost
	)

	for enemy: EnemySpec in enemies:
		_total_enemy_cost += enemy.cost

	_next_level()

	castle.game_over.connect(_on_game_over)


func _physics_process(_delta: float) -> void:
	var now := Time.get_ticks_usec()

	while not _event_queue.is_empty() and _event_queue.back().t <= now:
		_process_event(_event_queue.pop_back())
		_try_finish_level()

	var r := _clamp_remap(now - _level_start_ticks, 0, ceili(LEVEL_TIME * 1e6), CURSOR_RADIUS_BIG, CURSOR_RADIUS_SMALL)
	cursor_manager.set_radius(r)


func _clamp_remap(v: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
	return remap(clampf(v, istart, istop), istart, istop, ostart, ostop)


func _process_event(ev: TimedEvent) -> void:
	print("Process event single=%s tide=%s" % [ev.spawn != null, ev.tide.size()])

	var m: EnemyMother = EnemyMother.get_instance()
	if ev.spawn != null:
		var inst: Node2D = ev.spawn.scene.instantiate()
		_initialize_child(inst)
		m.single_spawn(inst)

	if not ev.tide.is_empty():
		var insts: Array[Node2D] = []

		for p: EnemySpec in ev.tide:
			var inst: Node2D = p.scene.instantiate()
			_initialize_child(inst)
			insts.push_back(inst)

		m.tide_spawn(insts)


func _initialize_child(inst: Node) -> void:
	inst.connect_death_signal(_on_enemy_death)
	if inst.has_method("get_enemy_amount"):
		_active_enemies += inst.get_enemy_amount()
	else:
		_active_enemies += 1


func _on_enemy_death(enemy_score: int = 1) -> void:
	_active_enemies -= 1
	_score += enemy_score

	_try_finish_level()


func _try_finish_level() -> void:
	if _active_enemies > 0 or not _event_queue.is_empty():
		return

	_next_level()


func _next_level() -> void:
	_level_counter += 1
	print("Starting level %d" % _level_counter)

	var balance := ceili(remap(_level_counter, 1, 10, 50, 1000))
	var spec := _gen_level_spec(balance)

	print("Generated spec: enemies=%d tides=%d" % [spec.enemies.size(), spec.tides.size()])

	_execute_level_spec(spec)

	_level_start_ticks = Time.get_ticks_usec()


func _gen_level_spec(budget: int) -> LevelSpec:
	var big_wave_budget: int = budget * BIG_SPAWN_PERCENT / 100

	var big_waves: int = 0

	var max_big_waves := big_wave_budget / BIG_SPAWN_COST
	if max_big_waves > 0:
		big_waves = randi_range(1, max_big_waves)
		budget -= big_waves * BIG_SPAWN_COST

	var b: int = budget
	var res_enemies: Array[EnemySpec] = []

	while b > 0:
		var e :=_pick_enemy(b)
		if e != null:
			res_enemies.push_back(e)
			b -= e.cost

	res_enemies.shuffle()

	big_waves = mini(big_waves, res_enemies.size() / 2)

	var big_wave_enemies: Array[Array] = []

	if big_waves > 0:
		var idxs := _gen_numbers(big_waves, res_enemies.size() / 2, res_enemies.size())
		idxs.sort()
		idxs.reverse()

		for idx: int in idxs:
			var part := res_enemies.slice(idx)
			if part.size() <= 1:
				continue
			big_wave_enemies.push_back(part)
			res_enemies.resize(idx)

	var res := LevelSpec.new()
	res.tides = big_wave_enemies
	res.enemies = res_enemies

	return res


func _gen_numbers(n: int, low: int, high: int) -> Array[int]:
	# hopefully low and high are not far apart lol
	var res: Array[int]
	res.assign(range(low, high+1))
	res.shuffle()
	res.resize(mini(res.size(), n))
	return res


func _pick_enemy(budget: int) -> EnemySpec:
	if budget <= 0:
		push_error("_pick_enemy(%s)" % budget)
		return null

	var w := randi_range(1, mini(_total_enemy_cost, budget))

	for enemy: EnemySpec in enemies:
		w -= enemy.cost
		if w <= 0:
			return enemy

	return enemies.back()


func _execute_level_spec(spec: LevelSpec) -> void:
	var start := Time.get_ticks_usec() + 1000000 # in 1 sec

	_active_enemies = 0
	for i: int in spec.enemies.size():
		var delay: int = roundi(remap(i, 0, spec.enemies.size() - 1, 0, ceili(LEVEL_TIME * 1e6)))

		_event_queue.push_back(TimedEvent.single(start+delay, spec.enemies[i]))

	for i: int in spec.tides.size():
		var delay: int = roundi(remap(i, 0, spec.tides.size() - 1, ceili(LEVEL_TIME * 0.3 * 1e6), ceili(LEVEL_TIME * 1e6)))

		_event_queue.push_back(TimedEvent.many(start+delay, spec.tides[i]))

	_event_queue.sort()


func _on_game_over() -> void:
	var inst := GAME_OVER_SCENE.instantiate()
	inst.score = _score
	Transition.change_scene_instance(inst)


class LevelSpec:
	var enemies: Array[EnemySpec] = []
	var tides: Array[Array] = [] # Array[Array[EnemySpec]]


class TimedEvent:
	var t: int
	var spawn: EnemySpec
	var tide: Array[EnemySpec]

	static func single(time: int, v: EnemySpec) -> TimedEvent:
		var te := TimedEvent.new()
		te.t = time
		te.spawn = v
		return te

	static func many(time: int, v: Array[EnemySpec]) -> TimedEvent:
		var te := TimedEvent.new()
		te.t = time
		te.tide =  v
		return te
