extends Node2D


func _on_death_floor_body_entered(body: Gobbo) -> void:
	get_tree().reload_current_scene()
