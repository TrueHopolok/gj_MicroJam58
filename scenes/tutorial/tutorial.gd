class_name Tutorial
extends CanvasLayer


@export var hints: Dictionary[int, String]

@onready var label: Label = $Hint


func on_level_switched(level_num: int) -> void:
	if level_num in hints.keys():
		_show_hint(hints[level_num])


func _show_hint(hint: String) -> void:
	pass
