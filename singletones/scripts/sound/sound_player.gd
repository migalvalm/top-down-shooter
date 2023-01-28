extends Node

onready var audioPlayers = get_node("AudioPlayers")

enum types {
	WAV,
	OGG
}

func play_sound(sound, volume = 1.0, pitch_scale = 1.0) -> void:
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.pitch_scale = pitch_scale
			audioStreamPlayer.volume_db = volume
			audioStreamPlayer.stream = sound

			
			audioStreamPlayer.play()
			break

func load_audio_file(path, loop, type = types.WAV):
	var sfx = load(path)
	print(path)
	if type == types.WAV:
		sfx.loop_mode = 1 if loop else 0
	elif type == types.OGG:
		sfx.loop = loop
	
	return sfx

