class_name LevelTwo extends Levels


func _ready() -> void:
	super()

	GameState.current_level = "2"

	dialogue_tree.show_dialogue(GameState.current_level, "start")


func _on_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_three.tscn")
