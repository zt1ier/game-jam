class_name DialogueScene extends Control


const MAIN_SCENE: PackedScene = preload("res://main.tscn")


@export var label_animation_speed: float = 0.05
@export var punctuation_pauses: Array[String] = [".", ",", "?", "!"]


var is_animating: bool = false


@onready var label: RichTextLabel = $RichTextLabel


func _ready() -> void:
	GameManager.dialogue_scene = self

	await _intro_dialogue()
	GameManager.next_level() # intro dialogue sequence is level 0

	await get_tree().process_frame
	get_tree().change_scene_to_packed(MAIN_SCENE)


# lazy dev shares lazy code, hilarity ensues
func _intro_dialogue() -> void:
	await get_tree().create_timer(1.5).timeout

	var intro_1 = GameManager.get_dialogue("intro1") # Honey, it's not your fault
	label.text = intro_1
	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(1.5).timeout

	var intro_2 = GameManager.get_dialogue("intro2") # It's
	label.text = intro_2
	await animating_characters()
	await get_tree().create_timer(0.7).timeout
	await fading_characters()
	await get_tree().create_timer(1.0).timeout

	var intro_3 = GameManager.get_dialogue("intro3") # It's been a couple days
	label.text = intro_3
	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(1.5).timeout

	var intro_4 = GameManager.get_dialogue("intro4") # At least eat some food
	label.text = intro_4
	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(1.5).timeout

	var intro_5 = GameManager.get_dialogue("intro5") # Please
	label.text = intro_5
	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(2.0).timeout


func update_label() -> void:
	if is_animating:
		return

	is_animating = true

	var external_line = GameManager.get_dialogue("external")
	label.text = external_line

	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(1.5).timeout

	var internal_line = GameManager.get_dialogue("internal")
	label.text = internal_line

	await animating_characters()
	await get_tree().create_timer(1.0).timeout
	await fading_characters()
	await get_tree().create_timer(2.5).timeout

	is_animating = false


func animating_characters() -> void:
	if not is_instance_valid(label) or label.text == "":
		return

	var total := label.get_total_character_count()
	label.visible_characters = 0

	var timer := 0.0
	while label.visible_characters < total:
		# increment time and update visible characters
		timer += get_physics_process_delta_time()
		if timer >= label_animation_speed:
			timer = 0.0
			label.visible_characters += 1

			# pause a bit on periods and commas
			var char_index := label.visible_characters - 1
			if char_index >= 0 and char_index < total:
				var char := label.get_parsed_text()[char_index]
				if char in punctuation_pauses:
					await get_tree().create_timer(label_animation_speed * 10.0).timeout
					continue  # skip to next frame

		var scene_tree := get_tree()
		if scene_tree:
			await scene_tree.process_frame


func fading_characters() -> void:
	if not is_instance_valid(label):
		return

	var fade_time := 0.4 # duration of fade effect in seconds
	var fade_steps := 5 # number of fade increments
	var wait_time := fade_time / fade_steps

	for i in range(fade_steps):
		var t := float(fade_steps - i) / float(fade_steps)
		label.modulate.a = t # fade alpha
		await get_tree().create_timer(wait_time).timeout

	label.visible_characters = 0
	label.text = ""
	label.visible_characters = -1
	label.modulate.a = 1.0
