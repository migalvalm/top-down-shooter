extends Node

onready var audioPlayers = get_node("AudioPlayers")

func play_sound(sound) -> void:
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break

func load_audio_file(path, loop):
	var sfx = load(path)
	sfx.loop_mode = 1 if loop else 0
	
	return sfx
