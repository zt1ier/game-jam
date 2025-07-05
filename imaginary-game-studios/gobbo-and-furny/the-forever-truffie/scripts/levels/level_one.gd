class_name LevelOne extends Levels


@onready var truffie_spawner: TruffieSpawner = $TruffieSpawner


func _ready() -> void:
	super()

	GameState.current_level = "1"

	_run_tutorial()


func _run_tutorial() -> void:
	GameState.in_tutorial = true

	timer.paused = true
	truffie_spawner.pause_spawning()

	await dialogue_tree.show_dialogue("1", "start")

	truffie_spawner.spawn_truffie()
	await dialogue_tree.show_dialogue("1", "first_truffie")

	await dialogue_tree.show_dialogue("1", "first_junction")

	await dialogue_tree.show_dialogue("1", "gut_hint")

	timer.paused = false
	truffie_spawner.resume_spawning()

	GameState.in_tutorial = false


func _on_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_two.tscn")
