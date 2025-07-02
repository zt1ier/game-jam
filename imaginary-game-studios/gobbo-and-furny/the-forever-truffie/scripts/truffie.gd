class_name Truffie extends Area2D


@export var travel_speed: float = 150.0


var types: Array[String] = [
	"Normal",
	"Frozen",
	"Explosive",
]

var type: String = ""

var current_target: Node2D # can be Junction


@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_set_truffie_type()


func _process(delta: float) -> void:
	if current_target:
		position = position.move_toward(current_target.global_position, travel_speed * delta)
		if position.distance_to(current_target.global_position) < 5:
			move_to_next()


func _set_truffie_type() -> void:
	type = types.pick_random()

	# placeholders, please change to actual sprites
	match type:
		"Normal": collision_shape.debug_color = Color.WHITE
		"Frozen": collision_shape.debug_color = Color.BLUE
		"Explosive": collision_shape.debug_color = Color.RED


func move_to_next() -> void:
	if current_target.has_method("get_output"):
		current_target = current_target.get_output()
	else:
		_reached_endpoint()


func _reached_endpoint() -> void:
	if current_target:
		var endpoint = current_target as Endpoint
		var expected_type = current_target.type

		if expected_type == type:
			GutMeter.digest()
			print("digested: %s" % type)
		else:
			GutMeter.reject()
			print("rejected: %s" % type)

		print("gut value: %s" % GutMeter.gut_value)

	else:
		printerr("invalid current_target.. somehow")

	queue_free()
