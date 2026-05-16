class_name EnemyMother
extends Node2D


signal tide_finished()

const GROUP: String = "EnemyMother"
const DRAW: bool = true

@export var _inner_radius: float = 200.0
@export var _outer_radius: float = 300.0

var _tide_spawning: bool = false
var _tide_queue: Array[Node2D] = []


## Returns first instance in the game tree of the EnemySpawner.
static func get_instance() -> EnemyMother:
	var res := Engine.get_main_loop().get_first_node_in_group(GROUP) as EnemyMother
	if not is_instance_valid(res):
		push_error("Cannot get instance of EnemyMother: not added to scene.")
	return res


func _physics_process(_delta: float) -> void:
	if !_tide_spawning:
		return
	if _tide_queue.is_empty():
		_tide_spawning = false
		# TODO: start animation of tide going down
		# subscribe to animation finish
		_on_tide_ended()
		return
	_single_tide_spawn(_tide_queue.back())
	_tide_queue.pop_back()


func _on_tide_started() -> void:
	pass


func _on_tide_ended() -> void:
	tide_finished.emit()


# Spawns enemy on the tide, meaning between inner and outer radiuses.
#
# x^2 + y^2 = R^2
# 1. Do the same as single_spawn;
# 2. Then move point between differences of 2 radiuses.
func _single_tide_spawn(enemy: Node2D) -> void:
	if !is_instance_valid(enemy):
		push_error("[%s.single_tide_spawn]: invalid instance to spawn" % [GROUP])
		return
	var x: float = randf_range(-_outer_radius, _outer_radius)
	var y: float = sqrt(_outer_radius * _outer_radius - x * x) * [-1, 1].pick_random()
	var p: Vector2 = Vector2(x, y)
	p += p.direction_to(Vector2.ZERO) * randf_range(0, _outer_radius - _inner_radius)
	enemy.position = p
	add_child(enemy)
	print("[%s.single_tide_spawn]: spawned the %s on [%f; %f]" % [GROUP, enemy.name, p.x, p.y])


## Spawns enemy node on the outer radius.
##
## x^2 + y^2 = R^2;
## 1. Generates x from -R to R;
## 2. Calculates y = +-sqrt(R^2 - x^2);
## 3. Add node to a tree as a child.
func single_spawn(enemy: Node2D) -> void:
	if !is_instance_valid(enemy):
		push_error("[%s.single_spawn]: invalid instance to spawn" % [GROUP])
		return
	var x: float = randf_range(-_outer_radius, _outer_radius)
	var y: float = sqrt(_outer_radius * _outer_radius - x * x) * [-1, 1].pick_random()
	var p: Vector2 = Vector2(x, y)
	enemy.position = p
	add_child(enemy)
	print("[%s.single_tide_spawn]: spawned the %s on [%f; %f]" % [GROUP, enemy.name, p.x, p.y])


## Spawns enemies as a tide.
## Enemies will be spawned backwards, meaning FILO.
func tide_spawn(enemies: Array[Node2D]) -> void:
	if _tide_spawning:
		return
	_tide_spawning = true
	_tide_queue.append_array(enemies)
	# TODO: start animation of tide going up
	# subscribe to animation finish
	_on_tide_started()


######## DRAWING LOGIC ########

func _process(_delta: float) -> void:
	if DRAW && OS.is_debug_build():
		queue_redraw()

func _draw() -> void:
	if DRAW && OS.is_debug_build():
		draw_circle(global_position, _inner_radius, Color.RED, false)
		draw_circle(global_position, _outer_radius, Color.BLUE, false)

######## ############# ########
