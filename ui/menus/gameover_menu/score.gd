extends Label


func _ready() -> void:
	text = "Your score:        %d
Best score:         %d" % [Persistence.current_score, Persistence.best_score]
