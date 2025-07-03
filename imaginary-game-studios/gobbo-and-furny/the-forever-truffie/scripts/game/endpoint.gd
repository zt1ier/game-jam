class_name Endpoint extends Area2D


var type: String = ""


@onready var color_rect: ColorRect = $ColorRect


func set_type(new_type: String) -> void:
	type = new_type

	if not color_rect:
		await get_tree().process_frame

	# placeholders, please change to actual sprites
	match type:
		"Normal": color_rect.color = Color.SANDY_BROWN
		"Spicy": color_rect.color = Color.DARK_RED
		"Crunchy": color_rect.color = Color.DARK_ORANGE
		_: print("uh oh")
