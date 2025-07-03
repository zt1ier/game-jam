class_name TruffieSpawner extends Node2D


const TRUFFIE_SCENE = preload("res://scenes/game/truffie.tscn")


@export var spawn_interval: float = 4.0 # in seconds
@export var truffie_travel_speed: float = 150.0


var pipe_nodes: Array[Pipe] = []
var timer: float = 0.0

var waiting_for_resolution: bool = false
var has_shown_first_truffie: bool = false
var is_paused: bool = false


@onready var pipes: Node2D = $"../Pipes"
@onready var endpoint_manager: EndpointManager = $"../EndpointManager"
@onready var dialogue_tree: DialogueTree = $"../DialogueTree"


func _ready() -> void:
	if pipe_nodes.is_empty():
		for pipe in pipes.get_children():
			pipe_nodes.append(pipe)


func _process(delta: float) -> void:
	if is_paused:
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_truffie()


func spawn_truffie() -> void:
	if pipe_nodes.is_empty() or TRUFFIE_SCENE == null:
		return

	var pipe = pipe_nodes.pick_random()
	var truffie = TRUFFIE_SCENE.instantiate()

	truffie.position = pipe.get_child(0).global_position # assuming pipe's first child is spawnpoint
	truffie.current_target = pipe
	truffie.travel_speed = truffie_travel_speed

	truffie.connect("truffie_resolved", Callable(endpoint_manager, "_on_truffie_resolved"))

	add_child(truffie)


func pause_spawning() -> void:
	is_paused = true


func resume_spawning() -> void:
	is_paused = false
