class_name CursorManager
extends Node2D


signal clicked

const DEFAULT_RADIUS: float = 64

@export var cursor_texture: Resource
@export var cursor_hotspot: Vector2
@export var cursor_trace_scene: PackedScene
@export var cursor_area: CursorArea

@export_flags_2d_physics var enemy_collision_mask: int

var radius: float


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_hotspot)
	set_radius(DEFAULT_RADIUS)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"shoot"):
		return

	get_viewport().set_input_as_handled()

	var pos := get_global_mouse_position()

	_create_trace(pos)
	_try_hit_enemies(pos)

	clicked.emit()


func set_radius(r: float) -> void:
	radius = r
	cursor_area.set_radius(r)


func tween_radius(r: float) -> void:
	create_tween().tween_method(set_radius, radius, r, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _try_hit_enemies(pos: Vector2) -> void:
	var circle := CircleShape2D.new()
	circle.radius = radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0, pos)
	query.collision_mask = enemy_collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var hits := get_world_2d().direct_space_state.intersect_shape(query, 128)

	# In case we hit all vertexes of a star, do it in random order, to make the star sequence fail.
	hits.shuffle()

	for hit in hits:
		var enemy := hit.collider.get_parent() as Enemy
		enemy.take_damage()


func _create_trace(pos: Vector2):
	var node := cursor_trace_scene.instantiate() as CursorTrace
	node.global_position = pos
	add_child(node)
	node.set_radius(radius)
