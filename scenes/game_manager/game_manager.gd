class_name GameManager
extends Node


@export var enemies: Array[EnemySpec] = []

var _total_enemy_cost: int = 0

const LEVEL_TIME: float = 120.0
const MAX_BIG_SPAWNS: int = 5
const BIG_SPAWN_COST: int = 10

## how much of the budget goes towards big waves
const BIG_SPAWN_PERCENT: int = 40


func _ready() -> void:
	randomize()

	enemies.sort_custom(func(lhs: EnemySpec, rhs: EnemySpec) -> bool:
		return lhs.cost < rhs.cost
	)

	for enemy: EnemySpec in enemies:
		_total_enemy_cost += enemy.cost


	var asd := _gen_level_spec(200)
	for enemy in asd.enemies:
		print("enemy", enemy.cost)

	for tide in asd.tides:
		print("TIDE")
		for enemy in tide:
			print("enemy", enemy.cost)


func start() -> void:
	pass


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


class LevelSpec:
	var enemies: Array[EnemySpec] = []
	var tides: Array[Array] = [] # Array[Array[EnemySpec]]
