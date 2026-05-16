extends Control


var score: int


func _ready() -> void:
	$Label.text += "\nscore: %d" % score
