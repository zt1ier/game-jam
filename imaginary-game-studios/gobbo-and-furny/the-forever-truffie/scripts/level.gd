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


func _ready() -> void:
	GameState.connect("game_won", Callable(self, "_on_game_won"))
	GameState.connect("game_lost", Callable(self, "_on_game_lost"))

	GutMeter.dialogue_tree = dialogue_tree

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
	pass


func _on_game_lost() -> void:
	# change scene to loss
	print("noooooooo you lose")
