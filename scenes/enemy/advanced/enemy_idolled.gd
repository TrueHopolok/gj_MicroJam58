class_name EnemyIdolled
extends Enemy


const CIRCLE_RADIUS: float = 10.0

var enemies: Dictionary[Enemy, bool]

@onready var _impossible_sfx_player: AudioStreamPlayer = get_tree().get_first_node_in_group('ImpossibleSFX')


func _physics_process(delta: float) -> void:
	super(delta)
	queue_redraw()


func _draw() -> void:
	if enemies.is_empty():
		return
	draw_circle(Vector2.ZERO, CIRCLE_RADIUS, Color.ORANGE, false, 2.0)
	for enemy in enemies:
		draw_dashed_line(to_local(global_position), to_local(enemy.global_position), Color.ORANGE, 1.0)


func idol_died(enemy: Enemy) -> void:
	enemies.erase(enemy)


func take_damage() -> void:
	if enemies.is_empty():
		super()
	else:
		_impossible_sfx_player.play()
