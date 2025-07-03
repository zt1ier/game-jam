class_name Truffie extends Area2D


signal truffie_resolved


var travel_speed: float = 0.0


var types: Dictionary[String, Array] = {
	"1": ["Normal", "Spicy"],
	"2": ["Normal", "Spicy", "Crunchy"],
	"3": ["Normal", "Spicy", "Crunchy"],
}

var type: String = ""

var current_target: Node2D # can be Junction


@onready var color_rect: ColorRect = $ColorRect
@onready var dialogue_tree: DialogueTree = $"../../DialogueTree"


func _ready() -> void:
	add_to_group("Truffies")

	_set_truffie_type()

	if not dialogue_tree.is_displaying:
		var level = GameState.current_level
		dialogue_tree.maybe_show_type_dialogue(level, type)


func _process(delta: float) -> void:
	if current_target:
		position = position.move_toward(current_target.global_position, travel_speed * delta)
		if position.distance_to(current_target.global_position) < 5:
			move_to_next()


func _set_truffie_type() -> void:
	var level = GameState.current_level
	var level_types = types.get(level, types["1"]) # fallback to level 1 types if key missing
	
	if level_types and not level_types.is_empty():
		type = level_types.pick_random()
	else:
		type = "Normal"

	# placeholders, please change to actual sprites
	match type:
		"Normal": color_rect.color = Color.SANDY_BROWN
		"Spicy": color_rect.color = Color.DARK_RED
		"Crunchy": color_rect.color = Color.DARK_ORANGE


func move_to_next() -> void:
	if current_target.has_method("get_output"):
		current_target = current_target.get_output()
	else:
		_reached_endpoint()


func _reached_endpoint() -> void:
	if current_target:
		var expected_type = current_target.type

		if expected_type == type:
			GutMeter.digest()
		else:
			GutMeter.reject()

	else:
		printerr("truffie.gd: invalid current_target.. somehow")

	truffie_resolved.emit()
	remove_from_group("Truffies")
	queue_free()
