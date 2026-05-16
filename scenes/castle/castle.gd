extends Area2D

signal game_over

@export var hp: int = 3

var dead: bool = false

@onready var sprite: Sprite2D = $AnimatedSprite2D

func take_damage() -> void:
	if dead:
		return

	hp -= 1
	sprite.play(&"hit")
	if (hp < 0):
		dead = true
		game_over.emit()


func _ready() -> void:
	sprite.play(&"idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == &"hit":
		if dead:
			sprite.play(&"dead")
		else:
			sprite.play(&"idle")
