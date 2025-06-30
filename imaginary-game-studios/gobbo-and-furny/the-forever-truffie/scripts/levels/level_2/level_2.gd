class_name LevelTwo extends Node2D


func _on_floor_body_entered(body: Gobbo) -> void:
	get_tree().reload_current_scene()
