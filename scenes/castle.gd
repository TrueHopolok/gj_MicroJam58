extends Area2D

signal game_over

@export var hp = 10

func take_damage() -> void:
	hp -= 1
	if (hp < 0):
		game_over.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
