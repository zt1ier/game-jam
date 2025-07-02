class_name LevelOne extends Levels


func _on_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_two.tscn")
