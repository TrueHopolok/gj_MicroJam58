class_name Castle
extends Area2D

signal game_over

@export var hp: int = 3

var dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.play(&"idle")

	body_entered.connect(_get_kicked)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == &"hit":
		if dead:
			sprite.play(&"dead")
		else:
			sprite.play(&"idle")


func _get_kicked(body: Node2D) -> void:
	if body.has_method(&"target_reached"):
		body.target_reached()
	else:
		push_error("Castle: took damage from %s, which has no target_reached()." % body.name)
		body.queue_free()

	if dead:
		return

	hp -= 1
	sprite.play(&"hit")
	if hp <= 0:
		dead = true
		game_over.emit()
