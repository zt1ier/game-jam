class_name Level extends Node2D


@export var player: Player:
	get:
		if not player:
			player = get_tree().get_first_node_in_group("Player")
		return player


@onready var before: Marker2D = $IntroPositions/Before
@onready var after: Marker2D = $IntroPositions/After


func _ready() -> void:
	_intro_sequence()


func _intro_sequence() -> void:
	GameManager.intro_sequence = true

	player.global_position = before.global_position
	await _player_walking()

	GameManager.intro_sequence = false


func _player_walking() -> void:
	while player.global_position != after.global_position:
		player.global_position = lerp(
			player.global_position, 
			after.global_position, 
			player.speed * get_physics_process_delta_time())
		player.animation.play("WALKING")
		await get_tree().process_frame
