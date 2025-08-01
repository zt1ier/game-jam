class_name DisplayScreen extends Control


@export var level: Node2D = null

@export_group("Time")
@export var time: float = 0.0

@export_group("Text")
@export_multiline var text: String = ""
@export var text_display_time: float = 5.0


const LOOP_HINTS: Array[String] = [
	"Try again.",
	"Incorrect.",
	"Please comply.",
	"It’s okay to make mistakes.",
	"Are you doing this on purpose?",
]


@onready var label: Label = $Label
@onready var screen: ColorRect = $Screen


func _ready() -> void:
	if not level:
		level = get_parent()

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
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	label.text = "%02d:%02d" % [minutes, seconds]


func display_text(t: String) -> void:
	label.add_theme_font_size_override("font_size", 25)

	label.text = t


func correct() -> void:
	if not label.text == "":
		label.text = ""

	await get_tree().create_timer(1.75).timeout

	screen.color = Color.GREEN

	await get_tree().create_timer(2.0).timeout

	GameManager.next_level()


func incorrect() -> void:
	var hint = LOOP_HINTS.pick_random()
	display_text(hint)

	screen.color = Color("550000")
