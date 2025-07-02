class_name EndpointManager extends Node2D


@export var retype_interval: float = 15.0
@export var endpoint_nodes: Array[Endpoint]


var types: Array[String] = [
	"Normal",
	"Frozen",
	"Explosive",
]

var retype_timer: float = 0.0

@onready var endpoints: Node2D = $"../Endpoints"


func _ready() -> void:
	if endpoint_nodes.is_empty():
		for endpoint in endpoints.get_children():
			endpoint_nodes.append(endpoint)

	set_unique_types()


func _process(delta: float) -> void:
	retype_timer += delta


func set_unique_types() -> void:
	var shuffled_types := types.duplicate()
	shuffled_types.shuffle()

	for i in endpoint_nodes.size():
		var endpoint = endpoint_nodes[i]
		if endpoint.has_method("set_type"):
			endpoint.set_type(shuffled_types[i])


func _on_truffie_resolved() -> void:
	if retype_timer >= retype_interval:
		if get_tree().get_nodes_in_group("Truffies").is_empty():
			set_unique_types()
			retype_timer = 0.0
