class_name EndScreen extends Level


@export var gmtk_float_speed: float = 2.0
@export var gmtk_float_strength: float = 5.0


var gmtk_float_timer: float = 0.0
var gmtk_base_position: Vector2 = Vector2.ZERO
var gmtk_base_rotation: float = 0.0

var times: Array[float] = []


@onready var gmtk_2025_logo: Sprite2D = $EndScreenStuff/GMTK
@onready var times_label: Label = $EndScreenStuff/TimesLabel


func _ready() -> void:
	_add_times()

	gmtk_base_position = gmtk_2025_logo.global_position
	gmtk_base_rotation = gmtk_2025_logo.rotation_degrees


func _physics_process(delta: float) -> void:
	gmtk_float_timer += get_physics_process_delta_time() * gmtk_float_speed

	# float animation
	var offset_x := sin(float_timer) * gmtk_float_strength
	var offset_y := cos(float_timer) * gmtk_float_strength
	gmtk_2025_logo.position.x = gmtk_base_position.x + offset_x
	gmtk_2025_logo.position.y = gmtk_base_position.y + offset_y

	# slight rotation
	gmtk_2025_logo.rotation_degrees = base_rotation + sin(gmtk_float_timer * 0.8) * rotate_strength


func _add_times() -> void:
	var raw_times := GameManager.get_times()
	var result_text := ""

	for i in range(raw_times.size()):
		var formatted_time := GameManager.format_time(raw_times[i])
		result_text += "Level %d: %s\n" % [i + 1, formatted_time]

	times_label.text = result_text.strip_edges()
