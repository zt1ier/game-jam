class_name Truffvine extends Node2D


@onready var vine_start: StaticBody2D = $VineStart
@onready var vine_end: RigidBody2D = $VineEnd
@onready var area_detect: Area2D = $VineEnd/Area2D
@onready var draw_line: Line2D = $Line2D
@onready var pin_joint: PinJoint2D = $PinJoint2D

@onready var vine_end_collision: CollisionShape2D = $VineEnd/CollisionShape2D


var gobbo: Gobbo = null
var gobbo_collision: CollisionShape2D = null

var is_gobbo_nearby: bool = false
var is_attached: bool = false

var attach_joint: PinJoint2D = null


func _ready() -> void:
	gobbo = get_tree().get_first_node_in_group("Gobbo")

	pin_joint.angular_limit_enabled = true
	pin_joint.angular_limit_lower = deg_to_rad(-120)
	pin_joint.angular_limit_upper = deg_to_rad(120)

	if not area_detect.is_connected("body_entered", Callable(self, "_on_body_entered")):
		area_detect.connect("body_entered", Callable(self, "_on_body_entered"))
	if not area_detect.is_connected("body_exited", Callable(self, "_on_body_exited")):
		area_detect.connect("body_exited", Callable(self, "_on_body_exited"))


func _process(delta: float) -> void:
	draw_line.points = [vine_start.position, vine_end.position]


func _physics_process(delta: float) -> void:
	# swing logic
	var truffie_value := TruffieManager.truffie_meter
	var swing_multiplier = clamp(1.0 - (truffie_value / 50.0), 0.2, 1.0)
	var swing_force = sin(Time.get_ticks_msec() * swing_multiplier) * 8000.0
	vine_end.apply_torque(swing_force)
	print(swing_force)

	# interaction logic
	if is_gobbo_nearby and not is_attached and Input.is_action_just_pressed("interact"):
		_attach_gobbo()
	elif is_attached and Input.is_action_just_pressed("interact"):
		_detach_gobbo()
	elif is_attached:
		_swing_gobbo()
	else:
		_unswing_gobbo()


func _attach_gobbo() -> void:
	if not gobbo or is_attached:
		return

	print("attached bro")

	is_attached = true
	gobbo.set_physics_process(false) # disable movement


func _detach_gobbo() -> void:
	if not is_attached:
		return

	print("detached bro")

	is_attached = false
	if gobbo:
		gobbo.set_physics_process(true) # enable movement


func _swing_gobbo() -> void:
	if not gobbo:
		return

	gobbo_collision = gobbo.get_child(0) # assuming first child is collision
	gobbo_collision.disabled = true

	gobbo.global_position = vine_end.global_position
	gobbo.global_rotation = vine_end.global_rotation


func _unswing_gobbo() -> void:
	if not gobbo:
		return

	gobbo_collision = gobbo.get_child(0) # assuming first child is collision
	gobbo_collision.disabled = false

	gobbo.global_rotation = deg_to_rad(0)


func _on_body_entered(body: Gobbo) -> void:
	if not gobbo:
		gobbo = body

	is_gobbo_nearby = true


func _on_body_exited(body: Gobbo) -> void:
	if not gobbo:
		gobbo = body

	is_gobbo_nearby = false
