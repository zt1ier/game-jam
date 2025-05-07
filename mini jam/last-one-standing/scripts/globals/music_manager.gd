extends AudioStreamPlayer


const MUSIC = preload("res://assets/w1A7feISNjp-z-0-y-681187776f87f1798f5c3133.ogg")
const MAIN = preload("res://main.tscn")


func _ready() -> void:
	stream = MUSIC
	play()


func _physics_process(delta: float) -> void:
	if not playing:
		play()
