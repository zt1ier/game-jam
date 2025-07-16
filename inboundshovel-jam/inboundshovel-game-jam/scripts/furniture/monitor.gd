class_name Monitor extends Node3D


var is_on: bool = true


@onready var turned_on_visual: Node3D = $TurnedOnVisual


# toggle between on and off for monitor
func _on_monitor_toggled(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		is_on = !is_on
		turned_on_visual.visible = !turned_on_visual.visible
