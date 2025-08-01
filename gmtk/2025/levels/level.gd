class_name Level extends Node2D


@export var player: Player:
	get:
		if not player:
			player = get_tree().get_first_node_in_group("Player")
		return player


@onready var before: Marker2D = $IntroPositions/Before
@onready var after: Marker2D = $IntroPositions/After

@onready var display_screen: DisplayScreen = $DisplayScreen


func _ready() -> void:
	GameManager.tree = get_tree()

	await _intro_sequence()


func _intro_sequence() -> void:
	GameManager.intro_sequence = true

	player.global_position = before.global_position
	await _player_walking()
	await _player_turning()

	GameManager.intro_sequence = false


func _player_walking() -> void:
	var speed := player.speed * 0.4
	var threshold := 2.0

	# slower walking speed 
	player.main_anim.speed_scale = 0.5
	player.shadow_anim.speed_scale = 0.5

	player.main_anim.frame = 0
	player.shadow_anim.frame = 0

	player.main_anim.play("WALKING")
	player.shadow_anim.play("WALKING")

	while player.global_position.distance_to(after.global_position) > threshold:
		var direction := (after.global_position - player.global_position).normalized()
		player.global_position += direction * speed * get_physics_process_delta_time()

		await get_tree().process_frame

	# snap to target after reaching threshold
	player.global_position = after.global_position

	# animation stuff
	player.main_anim.play("IDLE")
	player.shadow_anim.play("IDLE")

	player.main_anim.pause()
	player.shadow_anim.pause()

	# reset walking speed
	player.main_anim.speed_scale = 1.0
	player.shadow_anim.speed_scale = 1.0


func _player_turning() -> void:
	await get_tree().create_timer(1.5).timeout

	player.main_anim.flip_h = true
	player.shadow_anim.flip_h = true

	await get_tree().create_timer(1.5).timeout

	player.main_anim.flip_h = false
	player.shadow_anim.flip_h = false

	await get_tree().create_timer(1.0).timeout

	player.main_anim.play("IDLE")
	player.shadow_anim.play("IDLE")
