extends Enemy


signal clicked

var immune: bool = false
var _initial_speed: float = 0

@onready var ring: Node2D = $Ring


func _ready() -> void:
	_initial_speed = speed
	super()
	speed = 0


# override
func take_damage() -> void:
	clicked.emit()


func start_running() -> void:
	speed = _initial_speed


func reset() -> void:
	self.modulate.a = 1.0
	ring.hide()


func mark_target() -> void:
	ring.show()


func mark_clicked() -> void:
	reset()
	self.modulate.a = 0.5


func die() -> void:
	_die()
