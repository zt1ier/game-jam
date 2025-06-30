class_name Levels extends Node2D


@onready var high_nodes: Node2D = $HighTruffieNodes
@onready var low_nodes: Node2D = $LowTruffieNodes
@onready var truffie_meter: ProgressBar = $TruffieMeter


func _ready() -> void:
	TruffieManager.connect("meter_changed", Callable(self, "_on_truffie_meter_changed"))

	truffie_meter.max_value = 50

	_on_truffie_meter_changed()


func _on_truffie_meter_changed() -> void:
	pass


func _set_nodes(nodes: Node, enabled: bool) -> void:
	for node in nodes.get_children():
		if not node:
			continue
		node.visible = enabled
		if node is CollisionObject2D:
			for child in node.get_children():
				if child is CollisionShape2D:
					child.disabled = not enabled
