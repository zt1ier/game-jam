class_name LevelOne extends Level


@onready var menu_buttons: Array[Button] = [ $MenuStuff/StartButton, $MenuStuff/ExitButton ]


func _physics_process(delta: float) -> void:
	for button in menu_buttons:
		if button.visible:
			var base_text := button.text.strip_edges()
			if base_text.begins_with("[") and base_text.ends_with("]"):
				base_text = base_text.substr(2, base_text.length() - 4)   # remove brackets
			if button.is_hovered():
				button.text = "[ %s ]" % base_text
			else:
				button.text = base_text


func _on_platform_area_body_exited(_player: Player) -> void:
	display_screen.correct()


func _on_start_button_pressed() -> void:
	GameManager.in_main_menu = false
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	#$MenuStuff/ExitButton.text = "Why"
	get_tree().quit()
