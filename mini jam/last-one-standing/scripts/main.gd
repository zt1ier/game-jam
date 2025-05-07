extends Node2D


const NUMBER_SCENE = preload("res://scenes/enemy.tscn")
const BUILDING_SCENE = preload("res://scenes/building.tscn")
const ROCK_SCENE = preload("res://scenes/rock.tscn")
const TREE_SCENE = preload("res://scenes/tree.tscn")

var spawnable_objects: Array = [
	BUILDING_SCENE, 
	ROCK_SCENE, 
	TREE_SCENE
]


@export_subgroup("Parameters")
@export var max_enemies: int = 15
@export var spawn_interval: float = 4.0
@export var max_objects: int = 1000


var screen_size: Vector2
var displayed_points: int = 0


@onready var numbers: Control = $Numbers
@onready var background: ColorRect = $Background
@onready var values_label: Label = $UI/ValuesLabel
@onready var warning_label: Label = $UI/SelectWarning
@onready var confirm_label: Label = $UI/ConfirmLabel
@onready var zero_hint_label: Label = $UI/ZeroHintLabel
@onready var correct_sfx: AudioStreamPlayer = $CorrectSFX
@onready var incorrect_sfx: AudioStreamPlayer = $IncorrectSFX
@onready var warning_sfx: AudioStreamPlayer = $WarningSFX
@onready var points_label: Label = $UI/PointsLabel


func _ready() -> void:
	NumberValues.label = values_label
	NumberValues.zero_hint_label = zero_hint_label
	HeadsUpDisplay.warning_label = warning_label
	HeadsUpDisplay.confirm_label = confirm_label
	NumberValues.warning_sfx = warning_sfx
	HeadsUpDisplay.warning_sfx = warning_sfx
	
	NumberValues.c_sfx = correct_sfx
	NumberValues.i_sfx = incorrect_sfx
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	screen_size = get_viewport_rect().size
	$Cursor.show()
	
	MusicManager.volume_db = -100.0
	MusicManager.stop()
	
	randomize()
	for i in range(max_objects):
		spawn_object()
	
	spawn_loop()


func _physics_process(_delta: float) -> void:
	$Cursor.global_position = get_global_mouse_position()
	
	if not $Music.playing:
		$Music.play()
	
	handle_points()


func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		
		var num_of_enemies := get_tree().get_nodes_in_group("Enemies").size()
		
		if num_of_enemies < max_enemies:
			spawn_enemy()
		
		spawn_interval = max(spawn_interval * 0.99, 0.7)


func spawn_enemy() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("'Player' not found.")
		return
	
	var angle := randf() * TAU ## random angle
	var distance := screen_size.x / 2 + randf_range(50, 150) ## screen edge + small random
	
	var spawn_position := player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	var enemy := NUMBER_SCENE.instantiate()
	enemy.global_position = spawn_position
	enemy.add_to_group("Enemies")
	add_child(enemy)
	
	var partial_sum = NumberValues.get_current_partial_sum()
	
	## 50% chance to spawn desired number
	if randi() % 2 == 0 and partial_sum != 0:
		enemy.number = -partial_sum
	else:
		enemy.roll_number()
	
	enemy.update_label()


func spawn_object() -> void:
	var object_scene = spawnable_objects[randi() % spawnable_objects.size()]
	var object = object_scene.instantiate()
	
	var player: Player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	var distance = randf_range(50.0, 50000.0)
	var angle = randf() * TAU
	
	var spawn_position = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	object.global_position = spawn_position
	object.scale = Vector2(randf_range(1, 2), randf_range(1, 2))
	
	add_child(object)


func handle_points() -> void:
	displayed_points = lerp(displayed_points, PointsHandler.points, 0.5)
	
	if displayed_points == 1:
		points_label.text = str(displayed_points) + " Point"
	else:
		points_label.text = str(displayed_points) + " Points"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
