class_name LevelOne extends Node2D


const TRUFFROOT_CHUNK = preload("res://scenes/levels/level_1/truffroot_chunk.tscn")


var original_chunks: Array[TruffrootChunk] = []
var chunk_positions: Array[Vector2] = []
var active_chunks: int = 0


@onready var high_nodes: Node2D = $HighTruffieNodes
@onready var low_nodes: Node2D = $LowTruffieNodes
@onready var truffie_meter: ProgressBar = $TruffieMeter


func _ready() -> void:
	TruffieManager.connect("meter_changed", Callable(self, "_on_truffie_meter_changed"))

	truffie_meter.max_value = 50

	_on_truffie_meter_changed()

	# store initial chunk references and positions
	for chunk in low_nodes.get_children():
		if chunk is TruffrootChunk:
			original_chunks.append(chunk)
			chunk_positions.append(chunk.global_position)
			chunk.connect("done_falling", Callable(self, "_on_chunk_done_falling"))
			chunk.hide()

	# begin first drop cycle
	_start_drop_cycle()


func _start_drop_cycle() -> void:
	if active_chunks > 0:
		return

	active_chunks = original_chunks.size()

	for i in range(original_chunks.size()):
		var chunk := original_chunks[i]
		var target_pos := chunk_positions[i]
		chunk.reset(target_pos)


func _on_chunk_done_falling(chunk: TruffrootChunk) -> void:
	active_chunks -= 1
	if active_chunks <= 0:
		_start_drop_cycle()


func _on_truffie_meter_changed() -> void:
	truffie_meter.value = TruffieManager.truffie_meter
	if TruffieManager.truffie_meter >= 30:
		_set_nodes(high_nodes, true)
		_set_nodes(low_nodes, false)
	else:
		_set_nodes(high_nodes, false)
		_set_nodes(low_nodes, true)

		print(active_chunks)
		if active_chunks <= 0:
			_start_drop_cycle()


func _set_nodes(nodes: Node, enabled: bool) -> void:
	for node in nodes.get_children():
		if not node:
			continue
		node.visible = enabled
		if node is CollisionObject2D:
			for child in node.get_children():
				if child is CollisionShape2D:
					child.disabled = not enabled
