class_name Levels extends Node


@export_group("Lerps")
@export var display_lerp: float = 7.0
@export var difficulty_lerp: float = 0.01

@export_group("Difficulty Targets")
@export var target_truffie_speed: float = 300.0
@export var target_spawn_interval: float = 1.5


@onready var gut_meter: ProgressBar = $GutMeter
@onready var time_label: Label = $TimeLabel
@onready var timer: Timer = $Timer

@onready var endpoint_manager: EndpointManager = $EndpointManager
@onready var dialogue_tree: DialogueTree = $DialogueTree
@onready var truffies: TruffieSpawner = $Truffies


@onready var game_over: CanvasLayer = $GameOver
@onready var explosion: AnimatedSprite2D = $GameOver/Explosion
@onready var lose_panel: ColorRect = $GameOver/LosePanel


func _ready() -> void:
	if game_over.visible == true:
		game_over.hide()

	GameState.connect("game_won", Callable(self, "_on_game_won"))
	GameState.connect("game_lost", Callable(self, "_on_game_lost"))

	GutMeter.dialogue_tree = dialogue_tree
	GutMeter.refresh()

	# level resets
	if GutMeter.first_digest == false:
		GutMeter.first_digest = true
	if GutMeter.first_reject == false:
		GutMeter.first_reject = true


func _process(delta: float) -> void:
	time_label.text = "Time left: %.2f" % timer.time_left

	gut_meter.value = lerp(gut_meter.value, GutMeter.gut_pressure, delta * display_lerp)

	_slowly_increase_difficulty(delta)


func _slowly_increase_difficulty(delta: float) -> void:
	if not truffies:
		return


	truffies.truffie_travel_speed = lerp(truffies.truffie_travel_speed, \
	target_truffie_speed, delta * difficulty_lerp)

	truffies.spawn_interval = lerp(truffies.spawn_interval, \
	target_spawn_interval, delta * (difficulty_lerp / 2))


func _on_timer_timeout() -> void:
	GameState.game_won.emit()


func _on_game_won() -> void:
	_game_victory()


func _on_game_lost() -> void:
	_game_over()


func _game_victory() -> void:
	dialogue_tree.show_dialogue(GameState.current_level, "won")
	await dialogue_tree.wait_until_hidden()

	var next_level := int(GameState.current_level) + 1
	var next_level_scene = "res://scenes/levels/level_%d.tscn" % next_level
	
	if ResourceLoader.exists(next_level_scene):
		get_tree().change_scene_to_file(next_level_scene)
	else:
		print("level.gd: no more levels, make a victory scene that shows stats")
		pass


func _game_over() -> void:
	get_tree().paused = true

	dialogue_tree.show_dialogue(GameState.current_level, "lose")
	await dialogue_tree.wait_until_hidden()

	explosion.show()
	explosion.play("default")
	await explosion.animation_finished

	explosion.hide()
