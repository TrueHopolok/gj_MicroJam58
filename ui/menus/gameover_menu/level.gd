extends Label


func _ready() -> void:
	text = "Your level:        %d
Best level:         %d" % [Persistence.current_level + 1, Persistence.best_level + 1]
