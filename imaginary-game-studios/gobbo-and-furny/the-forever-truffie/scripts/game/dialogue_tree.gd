class_name DialogueTree extends CanvasLayer


var gobbo_dialogue: Dictionary = {



	"1":
		{
			"start": 
				["Alright Furny, we’re in! Time to sort some truffies!"],
			"first_truffie": 
				["See that? That’s a truffie. We gotta send it to its same-color exit!"],
			"first_junction": 
				["Those gray squares? You can swap its direction with [SPACE] when you’re close!"],
			"first_correct": 
				["That’s the stuff! Right exit, happy belly."],
			"first_wrong": 
				["Eugh! Wrong exit!"],
			"gut_hint": 
				["Don’t let that belly meter fill up or we’re toast!"],
			"type_normal": 
				[
					"Oooh, a classic! The brown truffies are tasty!",
					"See that color? That means it's just a regular truffie.",
				],
			"type_spicy": 
				[
					"Whoo! That one’s spicy!",
					"Hot stuff! Send it where the red one is.",
				],
		},



	"2":
		{
			"start": ["Rise and shine, Furny. Let’s not mess it up!"],
			"first_correct": 
				["Correct exit! You get five big booms!"],
			"first_wrong": 
				["Bad call! Wrong color!"],
			"type_normal": 
				[
					"Nothing beats the classic!",
					"Still normal. Still tasty.",
					"Brown means chewy. Easy pick.",
				],
			"type_spicy": 
				[
					"That’s one angry truffie!",
					"This one's got a kick to it!",
				],
			"type_crunchy":
				[
					"Sounds like bones... but I’m not asking questions.",
					"Crunch alert! Hope that wasn’t bones.",
					"Yum... crunch!",
				],
			"gut_warning": 
				[
					"Furny, the pressure’s building!",
					"I don't feel so good..!",
					"Pressure's going up...!",
				],
		},



	"3":
		{
			"start": ["Oh boy. Four pipes? Whose idea was this?!"],
			"first_correct": 
				["Yes! That’s how we keep the gut happy!"],
			"first_wrong": 
				["Nope! That one’s not gonna digest right!"],
			"type_normal": 
				[
					"Nothing beats the classic!",
					"Still normal. Still tasty.",
				],
			"type_spicy": 
				[
					"Don’t sniff it, Furny! My nose got itchy!",
					"It’s red and angry, like my uncle after beans.",
				],
			"type_crunchy":
				[
					"Hope this crunchy one doesn't chip anything.",
					"Orange again? Hope that’s not gravel.",
					"Yum... crunch!",
				],
			"gut_warning": 
				[
					"Furny, the pressure’s building!",
					"I don't feel so good..!",
					"Pressure's going up...!",
				],
		}
}


var shown_type_lines: Dictionary = {}

var display_time: float = 4.0
var is_displaying: bool = false


@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label


func _ready() -> void:
	panel.hide()


func maybe_show_type_dialogue(level: String, truffie_type: String) -> void:
	var type_key = "type_%s" % truffie_type.to_lower()

	if not gobbo_dialogue.has(level):
		print("no level in gobbo_dialogue")
		return
	if not gobbo_dialogue[level].has(type_key):
		print("no type_key in gobbo_dialogue[level]")
		return

	if not shown_type_lines.has(level):
		shown_type_lines[level] = []

	var already_shown = shown_type_lines[level] as Array

	if truffie_type not in already_shown:
		shown_type_lines[level].append(truffie_type)
		show_dialogue(level, type_key)
	elif randf() < 0.3:
		show_dialogue(level, type_key)


func show_dialogue(level: String, key: String) -> void:
	if is_displaying:
		await wait_until_hidden()

	is_displaying = true

	var level_dialogue = gobbo_dialogue.get(level, {})
	var line = level_dialogue.get(key, "")

	if typeof(line) == TYPE_ARRAY:
		label.text = line.pick_random()
	else:
		label.text = str(line)

	panel.show()

	await get_tree().create_timer(display_time).timeout

	label.text = ""
	panel.hide()
	is_displaying = false


func wait_until_hidden() -> void:
	while is_displaying:
		await get_tree().process_frame
