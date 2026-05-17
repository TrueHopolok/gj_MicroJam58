class_name Butterfly
extends Enemy


@export var heal: int = 10

@onready var _heal_sfx_player: AudioStreamPlayer = GameplaySfxPlayer.get_audio_stream_player("CastleHeal")

func _die() -> void:
	super()
	Castle.get_instance().take_damage(damage)


func target_reached() -> int:
	queue_free()
	died.emit(score)
	_heal_sfx_player.play()
	return -heal
