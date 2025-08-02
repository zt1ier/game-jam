class_name LevelOne extends Level


@export var grace_period: float = 5.0


var task_id: int = 0   # increments every time a new countdown starts

var has_moved: bool = false
var on_platform: bool = false

var time_left: int = 0


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

	if on_platform and player.direction != 0.0 and time_left <= grace_period:
		has_moved = true


func _on_platform_area_body_entered(_player: Player) -> void:
	on_platform = true

	task_id += 1
	var my_id := task_id

	display_screen.screen.color = Color.BLACK

	var start_time := display_screen.time
	var elapsed := 0.0

	while my_id == task_id and elapsed < start_time:
		display_screen.display_time(start_time - elapsed)
		await get_tree().create_timer(1.0).timeout
		elapsed += 1.0

		time_left = start_time - elapsed

	if my_id == task_id and has_moved:
		display_screen.correct()
	elif my_id == task_id and not has_moved:
		await get_tree().create_timer(1.0).timeout
		display_screen.incorrect("")


func _on_platform_area_body_exited(_player: Player) -> void:
	if level_complete: 
		return

	on_platform = false
	has_moved = false

	display_screen.screen.color = Color.BLACK

	task_id += 1   # invalidate any running countdown loop
	await get_tree().create_timer(1.0).timeout
	display_screen.display_text(display_screen.text)


func _on_start_button_pressed() -> void:
	GameManager.in_main_menu = false
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
