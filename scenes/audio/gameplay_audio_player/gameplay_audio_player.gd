extends AudioStreamPlayer


@export var loop_stream: AudioStream

@onready var _bus_idx: int = AudioServer.get_bus_index(&'Music')
@onready var _effect_idx: int = 0


func _ready() -> void:
	finished.connect(func() -> void:
		stream = loop_stream
		play()
	)


func _physics_process(_delta: float) -> void:
	if OS.get_name() == "Web":
		if get_tree().paused:
			volume_db = -10
		else:
			volume_db = 0
	else:
		AudioServer.set_bus_effect_enabled(_bus_idx, _effect_idx, get_tree().paused)
