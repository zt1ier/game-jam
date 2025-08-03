class_name DisplayScreen extends Control


@export var level: Level = null
@export var arrow_completed: Sprite2D:
	get:
		if not arrow_completed:
			var child_count = get_parent().get_child_count()
			arrow_completed = get_parent().get_child(child_count - 1)
		return arrow_completed


@export_multiline var prompt: String = ""


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
	"Disobedience! Please!",
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

var hint_index: int = 0


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
	display_text(prompt)


func display_text(t: String) -> void:
	label.add_theme_font_size_override("font_size", 25)

	label.text = t


func correct() -> void:
	next_level_door.monitoring = true

	GameManager.level_times[GameManager.current_level] = level.secret_timer

	print(GameManager.get_times())

	if not label.text == "":
		label.text = ""

	await get_tree().create_timer(1.75).timeout

	screen.color = Color.GREEN

	await get_tree().create_timer(2.0).timeout

	enable_next_level_door()


func enable_next_level_door() -> void:
	# this is so bad I'm picking up crumbs rn
	# I'm sorry
	if get_tree().current_scene.name == "LevelFive":
		arrow_completed.hide()
	else:
		arrow_completed.show()

	for child in next_level_door.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = false
		next_level_door.monitoring = true


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
