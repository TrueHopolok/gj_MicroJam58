extends Node


@export var close_hole: bool = false


func _ready() -> void:
	if close_hole:
		$AnimationPlayer.queue_free()
		var wr := $SubViewport/WaterRect as CanvasItem
		var mat := (wr.material as ShaderMaterial)
		mat.set_shader_parameter("hole_rad", 0.0)
		mat.set_shader_parameter("hole_foam_thickness", 0.0)


func play_spawn_anim() -> void:
	$AnimationPlayer.play(&"move_in")
