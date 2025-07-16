class_name DialogueScene extends Control


@export var label_animation_speed: float = 0.05
@export var punctuation_pauses: Array[String] = [".", ",", "?", "!"]


var level_one_finished: bool = true # please remove in final build

var is_animating: bool = false


@onready var label: RichTextLabel = $RichTextLabel


func _ready() -> void:
	GameManager.dialogue_scene = self


# quick next_level input, please remove in final build
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if GameManager.current_level == 1 and not level_one_finished:
			update_label()
		else:
			GameManager.next_level()


func update_label() -> void:
	if level_one_finished == false:
		level_one_finished = true

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

		await get_tree().process_frame


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
