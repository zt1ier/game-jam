# the music are by Eric Matyas from soundimage.org
extends AudioStreamPlayer


var game_music_path: String = "res://assets/audio/cyber-dream-loop.mp3"
var menu_music_path: String = "res://assets/audio/automation.mp3"

var game_music: AudioStreamMP3 = null
var menu_music: AudioStreamMP3 = null


var start_button: Button = null


var game_started: bool = false


var base_volume


func _ready() -> void:
	base_volume = volume_linear

	_load_music()
	_loop_music()
	finished.connect(Callable(self, "_loop_music"))


func _load_music() -> void:
	game_music = load(game_music_path)
	game_music.resource_path = game_music_path

	menu_music = load(menu_music_path)
	menu_music.resource_path = menu_music_path


func _loop_music() -> void:
	if not game_started:
		stream = menu_music
	#else:
		#stream = game_music
	volume_linear = base_volume * 0.5
	play()


func _game_started() -> void:
	game_started = true
	#_loop_music()


func connect_start_button() -> void:
	start_button.pressed.connect(Callable(self, "_game_started"))
