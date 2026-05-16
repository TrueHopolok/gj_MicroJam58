extends Area2D

signal game_over

@export var hp: int = 3

var dead: bool = false

func take_damage() -> void:
	if !dead:
		hp -= 1
		$AnimatedSprite2D.play("hit")
		if (hp < 0):
			dead = true
			game_over.emit()


func _ready() -> void:
	$AnimatedSprite2D.play("idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		if dead:
			$AnimatedSprite2D.play("dead")
		else:
			$AnimatedSprite2D.play("idle")
