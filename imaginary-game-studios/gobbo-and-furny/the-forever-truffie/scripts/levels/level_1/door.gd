class_name LevelOneDoor extends Area2D


var is_player_nearby: bool = false


func _ready() -> void:
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))


func _physics_process(delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://scenes/levels/level_2/level_2.tscn")


func _on_body_entered(body: Gobbo) -> void:
	is_player_nearby = true


func _on_body_exited(body: Gobbo) -> void:
	is_player_nearby = false
