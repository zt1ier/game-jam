class_name LevelThree extends Levels


func _ready() -> void:
	super()

	GameState.current_level = "3"

	dialogue_tree.show_dialogue(GameState.current_level, "start")
