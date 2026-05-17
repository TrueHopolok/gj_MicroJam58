class_name SpawnPolicy
extends Resource


## Set of premade levels. Executed sequentially, overrides everything else.
@export var premade: Array[PremadeLevel]

@export var enemy_policy: Array[EnemySpec] = []

@export var tide_enemy_policy: Array[EnemySpec] = []

const DEFAULT_BALANCE: int = 100
@export var balance: Curve
@export var tide_balance: Curve

const DEFAULT_MAX_TIDES: int = 5
@export var max_tides: Curve

const DEFAULT_MIN_TIDES: int = 1
@export var min_tides: Curve

const DEFAULT_SPAWN_GAP_SECONDS: float = 0.7
@export var spawn_gap_seconds: Curve

const DEFAULT_TIDE_GAP_SECONDS: float = 10
@export var tide_gap_seconds: Curve

@export var cursor_start: Curve
@export var cursor_end: Curve
@export var cursor_clicks: Curve


func sample(level: int) -> Sample:
	if level >= 0 and level < premade.size():
		return _sample_from_premade(premade[level])

	var money: int
	if balance == null:
		money = DEFAULT_BALANCE
	else:
		money = ceili(balance.sample_baked(level))

	var money_tides: int
	if tide_balance == null:
		money_tides = DEFAULT_BALANCE
	else:
		money_tides = ceili(tide_balance.sample_baked(level))

	var low_tides: int
	if min_tides == null:
		low_tides = DEFAULT_MIN_TIDES
	else:
		low_tides = floori(min_tides.sample_baked(level))

	var high_tides: int
	if max_tides == null:
		high_tides = DEFAULT_MAX_TIDES
	else:
		high_tides = ceili(max_tides.sample_baked(level))

	high_tides = maxi(high_tides, low_tides)

	var tide_n := randi_range(low_tides, high_tides)

	var res := Sample.new()

	var tpol := tide_enemy_policy
	if tpol.is_empty():
		tpol = enemy_policy

	for _i: int in tide_n:
		var r := _gen_enemy_array(tpol, money_tides)
		if r.is_empty():
			continue
		res.tides.push_back(r)

	res.enemies = _gen_enemy_array(enemy_policy, money)

	if spawn_gap_seconds == null:
		res.enemy_spawn_interval = DEFAULT_SPAWN_GAP_SECONDS
	else:
		res.enemy_spawn_interval = spawn_gap_seconds.sample_baked(level)

	if tide_gap_seconds == null:
		res.tide_spawn_interval = DEFAULT_TIDE_GAP_SECONDS
	else:
		res.tide_spawn_interval = tide_gap_seconds.sample_baked(level)

	res.cursor_start = cursor_start.sample_baked(level)
	res.cursor_end = cursor_end.sample_baked(level)
	res.cursor_clicks = ceili(cursor_clicks.sample_baked(level))

	return res


func initialize() -> void:
	enemy_policy.sort_custom(_spec_cmp)
	tide_enemy_policy.sort_custom(_spec_cmp)


func _spec_cmp(lhs: EnemySpec, rhs: EnemySpec) -> bool:
	return lhs.cost < rhs.cost


func _gen_enemy_array(spec: Array[EnemySpec], b: int) -> Array[PackedScene]:
	var spec_total: int = 0
	for s: EnemySpec in spec:
		spec_total += s.weight

	var res: Array[PackedScene]

	while b > 0:
		var s := _select_with_w(spec, randi_range(1, spec_total), b)
		if s == null:
			break
		b -= s.cost
		res.push_back(s.scene)

	res.shuffle()

	return res


func _select_with_w(spec: Array[EnemySpec], w: int, b: int) -> EnemySpec:
	for v: EnemySpec in spec:
		if v.cost > b:
			break
		w -= v.weight
		if w <= 0:
			return v

	# find first that is good enough
	for v: EnemySpec in spec:
		if v.weight <= b:
			return v

	return null


func _sample_from_premade(pm: PremadeLevel) -> Sample:
	var es: Array[PackedScene]
	if pm.enemies != null:
		for key: PackedScene in pm.enemies.data:
			for _i: int in pm.enemies.data[key]:
				es.push_back(key)

	var ts: Array[Array]
	for t: EnemyList in pm.tides:
		var tide: Array[PackedScene]
		for key: PackedScene in t.data:
			for _i: int in t.data[key]:
				tide.push_back(key)
		ts.push_back(tide)

	var res := Sample.new()
	res.enemies = es
	res.enemy_spawn_interval = pm.length / res.enemies.size()
	res.tides = ts
	res.tide_spawn_interval = pm.length / (res.tides.size() + 1)
	res.cursor_start = pm.cursor_start
	res.cursor_end = pm.cursor_end
	res.cursor_clicks = pm.cursor_clicks

	return res


class Sample:
	var enemies: Array[PackedScene]
	var enemy_spawn_interval: float
	var tides: Array[Array]
	var tide_spawn_interval: float

	var cursor_start: float
	var cursor_end: float
	var cursor_clicks: int
