extends AudioStreamPlayer


@export var loop_stream: AudioStream


func _ready() -> void:
	finished.connect(func() -> void:
		stream = loop_stream
		play()
	)
