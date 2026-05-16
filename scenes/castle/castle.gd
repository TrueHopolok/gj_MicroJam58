class_name Castle
extends Area2D


signal game_over

const GROUP: StringName = &"Castle"

@export var starting_health: int = 10

var health: int = starting_health

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_sprite.play(&"idle")
	body_entered.connect(_get_kicked)
	_sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if _sprite.animation == &"hit":
		if health <= 0:
			_sprite.play(&"dead")
		else:
			_sprite.play(&"idle")


func _get_kicked(body: Node2D) -> void:
	if body.has_method(&"target_reached"):
		var dmg: int = body.target_reached()
		take_damage(dmg)
	else:
		push_error("Castle: took damage from %s, which has no target_reached()." % body.name)
		body.queue_free()


func take_damage(dmg: int) -> void:
	if health <= 0:
		return
	health = clampi(health - dmg, 0, starting_health)
	if dmg > 0:
		_sprite.play(&"hit")
		if health <= 0:
			game_over.emit()


static func get_instance() -> Castle:
	return Engine.get_main_loop().get_first_node_in_group(GROUP)
