extends Node

class_name GameplaySfxPlayer


static func get_audio_stream_player(path: NodePath) -> AudioStreamPlayer:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group("SfxPlayer").get_node(path)
