extends Label


func _physics_process(_delta: float) -> void:
	text = String.num_int64(Persistence.current_score)
