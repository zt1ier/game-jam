class_name Endpoint extends Area2D


var type: String = ""


@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func set_type(new_type: String) -> void:
	type = new_type

	# placeholders, please change to actual sprites
	match type:
		"Normal": collision_shape.debug_color = Color.WHITE
		"Frozen": collision_shape.debug_color = Color.BLUE
		"Explosive": collision_shape.debug_color = Color.RED
