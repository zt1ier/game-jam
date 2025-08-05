class_name Level extends Node2D


@export var player: Player:
	get:
		if not player:
			player = get_tree().get_first_node_in_group("Player")
		return player

@export_group("Title Animation")
@export var float_speed: float = 1.0
@export var float_strength: float = 5.0
@export var rotate_strength: float = 1.5


var float_timer := 0.0
var base_position: Vector2 = Vector2.ZERO
var base_rotation: float = 0.0

var secret_timer: float = 0.0

var level_complete: bool = false


@onready var level_nodes: Array[Node] = [
	$Platform,
	$PlatformDropShadow, 
	$PlatformAreaDetect ,
	$DisplayScreen,
	$NextLevelDoor
]

@onready var menu_nodes: Array[Node] = [
	$MenuStuff/BlurEffect,
	$MenuStuff/Title,
	$MenuStuff/StartButton,
	$MenuStuff/ExitButton,
]

@onready var blur_effect: ColorRect = $MenuStuff/BlurEffect
@onready var menu_title: Label = $MenuStuff/Title


@onready var before: Marker2D = $IntroPositions/Before
@onready var after: Marker2D = $IntroPositions/After

@onready var display_screen: DisplayScreen = $DisplayScreen


func _ready() -> void:
	player.sword(false)
	set_process(false)
	GameManager.tree = get_tree()

	if get_tree().current_scene.name in [ "LevelOne", "EndScreen" ] :
		base_position = menu_title.global_position
		base_rotation = menu_title.rotation_degrees

		if GameManager.in_main_menu:
			await _main_menu(true)
			return

		await _main_menu(false)

	await _intro_sequence()
	set_process(true)


func _process(delta: float) -> void:
	secret_timer += delta


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


func _main_menu(yes: bool) -> void:
	blur_effect.visible = yes

	for node in level_nodes:
		node.visible = not yes

		# if node has collision or area children, disable
		if node.get_child_count() > 0:
			for child in node.get_children(true):
				if child is CollisionShape2D or child is CollisionPolygon2D:
					child.disabled = yes
					#print(child.get_path(), " disabled")
				if child is Area2D:
					child.monitoring = not yes
					child.monitorable = not yes

	for node in menu_nodes:
		node.visible = yes

	# spawn player in the center of the screen
	player.global_position.x = get_viewport_rect().size.x / 2

	# animate the menu title
	while GameManager.in_main_menu:
		_animate_title()

		if is_instance_valid(get_tree()):
			await get_tree().process_frame


func _animate_title() -> void:
	float_timer += get_physics_process_delta_time() * float_speed

	# float animation
	var offset_x := sin(float_timer) * float_strength
	var offset_y := cos(float_timer) * float_strength
	menu_title.position.x = base_position.x + offset_x
	menu_title.position.y = base_position.y + offset_y

	# slight rotation
	menu_title.rotation_degrees = base_rotation + sin(float_timer * 0.8) * rotate_strength


func _on_next_level_door_body_entered(player: Player) -> void:
	if get_tree().current_scene.name == "LevelFive":
		GameManager.level_times[GameManager.current_level] = secret_timer
	GameManager.next_level()
