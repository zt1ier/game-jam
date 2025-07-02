class_name TruffieSpawner extends Node2D


const TRUFFIE_SCENE = preload("res://scenes/truffie.tscn")


@export var spawn_interval: float = 4.0 # in seconds


var pipe_nodes: Array[Pipe] = []

var timer: float = 0.0


@onready var pipes: Node2D = $"../Pipes"


func _ready() -> void:
	if pipe_nodes.is_empty():
		for pipe in pipes.get_children():
			pipe_nodes.append(pipe)
	print(pipe_nodes)


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

	add_child(truffie)
	print("spawned truffie")
