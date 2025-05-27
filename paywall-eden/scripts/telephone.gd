class_name Telephone extends Button


func _ready() -> void:
	connect("pressed", Callable(self, "_on_pressed"))


func _on_pressed() -> void:
	_start_call()
	pass


func _start_call() -> void:
	_load_dialogue()


func _load_dialogue() -> void:
	pass
