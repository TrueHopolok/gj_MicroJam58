class_name EnemyTwin
extends Enemy


@export var _stun_duration: float = 3.0

var twin: EnemyTwin
var _stun_left: float = 0.0

@onready var _impossible_sfx_player: AudioStreamPlayer = get_tree().get_first_node_in_group('ImpossibleSFX')


func _physics_process(delta: float) -> void:
	if stunned():
		_sprite.animation = &"stunned"
		_stun_left = clampf(_stun_left - delta, 0.0, _stun_duration)
	else:
		_sprite.animation = &"default"
		super(delta)
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(twin):
		return
	draw_dashed_line(to_local(global_position), to_local(twin.global_position), Color.GREEN_YELLOW, 1.0)


func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	if health <= 0:
		if not is_instance_valid(twin):
			_die()
		elif twin.stunned():
			_die()
			twin._die()
		else:
			_impossible_sfx_player.play()
			health = 1
			_stun_left = _stun_duration


func stunned() -> bool:
	return _stun_left > 0.0
