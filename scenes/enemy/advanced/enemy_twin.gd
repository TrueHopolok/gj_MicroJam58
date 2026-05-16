class_name EnemyTwin
extends Enemy


@export var _stun_duration: float = 3.0

var twin: EnemyTwin
var _stun_left: float = 0.0


func _physics_process(delta: float) -> void:
	if stunned():
		_stun_left = clampf(_stun_left - delta, 0.0, _stun_duration)
	else:
		super(delta)
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(self) or not is_instance_valid(twin):
		return
	draw_line(to_local(global_position), to_local(twin.global_position), Color.WHITE)


func take_damage() -> void:
	if stunned() || health <= 0:
		return
	health -= 1
	if health <= 0:
		if twin.stunned():
			_die()
			twin._die()
		_stun_left = _stun_duration


func stunned() -> bool:
	return _stun_left > 0.0
