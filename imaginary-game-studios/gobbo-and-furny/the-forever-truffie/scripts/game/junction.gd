class_name Junction extends Area2D


@export var output_left: NodePath
@export var output_right: NodePath


var target_output: NodePath

var is_player_nearby: bool = false


@onready var left_marker: Marker2D = $LeftMarker
@onready var right_marker: Marker2D = $RightMarker
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# connect signals if not already
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

	# randomize target output
	if not target_output:
		target_output = [output_left, output_right].pick_random()


func _draw() -> void:
	# draw lines to both outputs
	if output_left and output_left:
		var to_left = to_local(get_node(output_left).global_position)
		var to_right = to_local(get_node(output_right).global_position)

		# colors
		var inactive_color = Color.GRAY
		var active_color = Color.RED

		var color_left = inactive_color
		var color_right = inactive_color

		# assign color for each line
		if target_output == output_left:
			color_left = active_color
		elif target_output == output_right:
			color_right = active_color

		draw_line(Vector2.ZERO, to_left, color_left, 3.0)
		draw_line(Vector2.ZERO, to_right, color_right, 3.0)


func _physics_process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		_change_output()


func _change_output() -> void:
	if target_output == output_left:
		target_output = output_right
		anim.play("output_R")
	elif target_output == output_right:
		target_output = output_left
		anim.play("output_L")
	queue_redraw()


func _on_body_entered(_body: Furny) -> void:
	is_player_nearby = true


func _on_body_exited(_body: Furny) -> void:
	is_player_nearby = false


func get_output() -> Node2D:
	return get_node(target_output)
