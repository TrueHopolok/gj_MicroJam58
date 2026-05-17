class_name EnemyIdolled
extends Enemy


const CIRCLE_RADIUS: float = 10.0

var enemies: Dictionary[Enemy, bool]


func _physics_process(delta: float) -> void:
	super(delta)
	queue_redraw()


func _draw() -> void:
	if enemies.is_empty():
		return
	draw_circle(Vector2.ZERO, CIRCLE_RADIUS, Color.CYAN, false)
	for enemy in enemies:
		draw_line(to_local(global_position), to_local(enemy.global_position), Color.CYAN)


func idol_died(enemy: Enemy) -> void:
	enemies.erase(enemy)


func take_damage() -> void:
	if enemies.is_empty():
		super()
