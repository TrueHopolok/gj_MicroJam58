@tool
extends Node2D


@export_tool_button("place children on a circle")
var arrange_children := _arrange_children

@export
var spam_arrange := false


func _arrange_children() -> void:
	var first := get_child(0)
	var initial := first.position as Vector2

	for i: int in get_child_count():
		if i == 0:
			continue
		var c := get_child(i) as Node2D
		c.position = initial.rotated(remap(i, 0, get_child_count(), 0, TAU))



func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() or not spam_arrange:
		return
	_arrange_children()
