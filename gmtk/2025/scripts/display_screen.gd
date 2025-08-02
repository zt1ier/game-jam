class_name DisplayScreen extends Control


@export var level: Level = null
@export var arrow_completed: Sprite2D:
	get:
		if not arrow_completed:
			var child_count = get_parent().get_child_count()
			arrow_completed = get_parent().get_child(child_count - 1)
		return arrow_completed


@export_group("Time")
@export var time: float = 0.0

@export_group("Text")
@export_multiline var text: String = ""
@export var text_display_time: float = 5.0

var hint_index: int = 0

const LOOP_HINTS: Array[String] = [
	"Try again.",
	"Incorrect.",
	"Please comply.",
	"It’s okay to make mistakes.",
	"Are you doing this on purpose?",
	"Think... outside the box!",
	"Should we tell them?",
	"Please stop...!",
	"It's been at least a minute.",
	"You're still here?",
	"In the first one?",
	"Thanks!",
	"Okay, fine. In the next one.",
	"The key is disobedience. Please.",
	"No way.",
	"No more.",
	"I wanna go home.",
	"Hi mom!",
	"This is the last one."
]


var float_time: float = 0.0
var float_speed: float = 3.0
var float_strength: float = 5.0
var base_arrow_x: float = 0.0


@onready var label: Label = $Label
@onready var screen: ColorRect = $Screen
@onready var next_level_door: Area2D = $"../NextLevelDoor"


func _ready() -> void:
	if not level:
		level = get_parent()

	arrow_completed.hide()
	base_arrow_x = arrow_completed.position.x
	next_level_door.monitoring = false

	reset_display()


func reset_display() -> void:
	display_text(text)
	if time == 0.0:
		return

	await get_tree().create_timer(text_display_time).timeout

	if time != 0.0:
		display_time(time)


func display_time(t: float) -> void:
	label.add_theme_font_size_override("font_size", 70)

	var total_seconds := int(t)
	#@warning_ignore("integer_division")   # what
	var minutes := total_seconds / 60.0   # man i just put .0 and the warning is gone
	var seconds := total_seconds % 60
	label.text = "%02d:%02d" % [minutes, seconds]


func display_text(t: String) -> void:
	label.add_theme_font_size_override("font_size", 25)

	label.text = t


func correct() -> void:
	next_level_door.monitoring = true

	GameManager.level_times[GameManager.current_level] = level.secret_timer

	if not label.text == "":
		label.text = ""

	await get_tree().create_timer(1.75).timeout

	screen.color = Color.GREEN

	await get_tree().create_timer(2.0).timeout

	arrow_completed.show()


func incorrect(text: String) -> void:
	if text.strip_edges() == "":
		var hint := ""
		if LOOP_HINTS.size() < hint_index:
			hint = "!SimonSays"
		else:
			hint = LOOP_HINTS[hint_index]
			hint_index += 1
		text = hint

	display_text(text)

	screen.color = Color("550000")


func _physics_process(delta: float) -> void:
	if arrow_completed.visible:
		float_time += delta * float_speed
		var wave = sin(float_time) * float_strength
		arrow_completed.position.x = base_arrow_x + wave
