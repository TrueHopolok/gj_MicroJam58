class_name EnemyIdolled
extends Enemy


var enemies: Dictionary[Enemy, bool]


func _physics_process(delta: float) -> void:
	super(delta)
	queue_redraw()


func _draw() -> void:
	for enemy in enemies:
		draw_line(to_local(global_position), to_local(enemy.global_position), Color.WHITE)


func idol_died(enemy: Enemy) -> void:
	enemies.erase(enemy)


func take_damage() -> void:
	if enemies.is_empty():
		super()
