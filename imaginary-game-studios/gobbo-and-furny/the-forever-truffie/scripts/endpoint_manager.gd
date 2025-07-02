class_name EndpointManager extends Node2D


@export var retype_interval: float = 15.0
@export var endpoint_nodes: Array[Endpoint]


var types: Array[String] = [
	"Normal",
	"Frozen",
	"Explosive",
]


@onready var endpoints: Node2D = $"../Endpoints"


func _ready() -> void:
	if endpoint_nodes.is_empty():
		for endpoint in endpoints.get_children():
			endpoint_nodes.append(endpoint)

	_set_unique_types()
	_start_retype_loop()


func _set_unique_types() -> void:
	var shuffled_types := types.duplicate()
	shuffled_types.shuffle()

	for i in endpoint_nodes.size():
		var endpoint = endpoint_nodes[i]
		if endpoint.has_method("set_type"):
			endpoint.set_type(shuffled_types[i])


func  _start_retype_loop() -> void:
	await get_tree().create_timer(retype_interval).timeout
	_set_unique_types()
	_start_retype_loop()
