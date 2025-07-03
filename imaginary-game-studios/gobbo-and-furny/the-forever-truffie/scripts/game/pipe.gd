class_name Pipe extends Marker2D


@export var target: NodePath
@onready var spawnpoint: Marker2D = $Spawnpoint


func _draw() -> void:
		if target:
			var to_target = to_local(get_node(target).global_position)

			draw_line(Vector2.ZERO, to_target, Color.WEB_GREEN, 3.0)


func get_output() -> Node2D:
	return get_node(target)
