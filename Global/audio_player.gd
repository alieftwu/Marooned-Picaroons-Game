extends AudioStreamPlayer2D

const world_music = preload("res://Audio/Pirate Music Pack/ogg/Pirate 1.ogg")
const startFight = preload("res://Audio/DrawSword.mp3")
const menuMusic = preload("res://Combat/Resources/sea_theme_1.wav")

func _play_music(music: AudioStream, volume = -8.0):
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()

func play_music_world():
	_play_music(world_music)

func play_draw_sword():
	_play_music(startFight)
	
func play_menu_music():
	_play_music(menuMusic)
