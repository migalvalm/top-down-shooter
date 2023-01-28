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

func load_audio_file(path, loop, type = ".wav"):
	var sfx = load(path)
	
	match get_audio_file_type(type):
		types.WAV:
			sfx.loop_mode = 1 if loop else 0
		types.OGG:
			sfx.loop = loop
	
	return sfx

func get_audio_file_type(type):
	if type == ".wav": 
		return SoundPlayer.types.WAV 
	else: 
		return SoundPlayer.types.OGG
