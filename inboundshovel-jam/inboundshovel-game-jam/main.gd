class_name Main extends Node3D


@export_group("Camera Angles")
@export var monitor_view: float = 0.0
@export var window_view: float = -PI / 1.65
@export var room_view: float = -PI
@export var bed_view: float = PI / 1.7

@export_group("Lazy Hardcoded Variables")
@export var door_closed_position: Vector3 = Vector3(0.027, 1.111, 3.0)
@export var door_closed_rotation: Vector3 = Vector3.ZERO
@export var door_opened_position: Vector3 = Vector3(-0.068, 1.111, 2.712)
@export var door_opened_rotation: Vector3 = Vector3(0.0, 43.8, 0.0) # degrees, need to turn to radians



enum LookingAt { MONITOR, WINDOW, ROOM, BED }
var looking_order: Array[LookingAt] = [LookingAt.MONITOR, LookingAt.WINDOW, LookingAt.ROOM, LookingAt.BED]

var looking_at: LookingAt = LookingAt.MONITOR
var can_turn: bool = true


@onready var camera: Camera3D = $Camera


func _physics_process(delta: float) -> void:
	if not can_turn:
		return

	if Input.is_action_just_pressed("turn_left"):
		_turn("left")
	elif Input.is_action_just_pressed("turn_right"):
		_turn("right")
	elif Input.is_action_just_pressed("turn_back"):
		_turn("back")


func _turn(direction: String) -> void:
	var index := looking_order.find(looking_at)
	if index == -1:
		return

	match direction:
		"left":
			index = (index - 1 + looking_order.size()) % looking_order.size()
		"right":
			index = (index + 1) % looking_order.size()
		"back":
			index = (index + 2) % looking_order.size()

	var target_view := looking_order[index]
	looking_at = target_view
	_turn_to(get_view_angle(target_view))


func get_view_angle(view: LookingAt) -> float:
	match view:
		LookingAt.MONITOR: return monitor_view
		LookingAt.WINDOW: return window_view
		LookingAt.ROOM: return room_view
		LookingAt.BED: return bed_view
		_: return monitor_view # default fallback


func _turn_to(target_angle: float) -> void:
	can_turn = false
	await _turning_head(target_angle)
	can_turn = true


func _turning_head(target_rotation: float) -> void:
	while abs(angle_difference(camera.rotation.y, target_rotation)) > 0.01:
		camera.rotation.y = lerp_angle(camera.rotation.y, target_rotation, 0.3)
		await get_tree().process_frame
