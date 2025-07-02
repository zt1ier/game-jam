class_name TruffieSpawner extends Node2D


const TRUFFIE_SCENE = preload("res://scenes/game/truffie.tscn")


@export var spawn_interval: float = 4.0 # in seconds

var truffie_travel_speed: float = 150.0 # default/base


var pipe_nodes: Array[Pipe] = []
var waiting_for_resolution: bool = false
var timer: float = 0.0


@onready var pipes: Node2D = $"../Pipes"
@onready var endpoint_manager: EndpointManager = $"../EndpointManager"


func _ready() -> void:
	if pipe_nodes.is_empty():
		for pipe in pipes.get_children():
			pipe_nodes.append(pipe)


func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		_spawn_truffie()


func _spawn_truffie() -> void:
	if pipe_nodes.is_empty() or TRUFFIE_SCENE == null:
		return

	var pipe = pipe_nodes.pick_random()
	var truffie = TRUFFIE_SCENE.instantiate()

	truffie.position = pipe.global_position
	truffie.current_target = pipe.get_output()
	truffie.travel_speed = truffie_travel_speed

	truffie.connect("truffie_resolved", Callable(endpoint_manager, "_on_truffie_resolved"))

	add_child(truffie)
