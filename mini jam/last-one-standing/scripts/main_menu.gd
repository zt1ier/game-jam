extends Control


var buttons: Array = []


func _ready() -> void:
	MusicManager.volume_db = 0.0
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$Cursor.show()
	
	for child in get_children():
		if child is Button:
			buttons.append(child)
			child.set_meta("base_text", child.text)


func _physics_process(delta: float) -> void:
	$Cursor.global_position = get_global_mouse_position()
	
	for child in get_children():
		if child is Button:
			hovered_animation(child)


func _on_play_pressed() -> void:
	$ClickSFX.pitch_scale = randf_range(1.5, 2.0)
	$ClickSFX.play()
	get_tree().change_scene_to_file("res://main.tscn")


func _on_exit_pressed() -> void:
	$ClickSFX.pitch_scale = randf_range(1.5, 2.0)
	$ClickSFX.play()
	get_tree().quit()


func _on_info_pressed() -> void:
	$ClickSFX.pitch_scale = randf_range(1.5, 2.0)
	$ClickSFX.play()
	get_tree().change_scene_to_file("res://scenes/menus/info_menu.tscn")


func hovered_animation(button: Button) -> void:
	var base_text = button.get_meta("base_text")
	
	if button.is_hovered():
		button.text = "▮ " + base_text
	else:
		button.text = base_text
