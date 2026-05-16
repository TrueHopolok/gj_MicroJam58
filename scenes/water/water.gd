extends Node


func play_spawn_anim() -> void:
	$AnimationPlayer.play(&"move_in")
