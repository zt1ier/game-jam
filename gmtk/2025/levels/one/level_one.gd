class_name LevelOne extends Level


var task_id: int = 0   # increments every time a new countdown starts


func _on_platform_area_body_entered(player: Player) -> void:
	task_id += 1
	var my_id := task_id

	display_screen.screen.color = Color.BLACK

	var start_time := display_screen.time
	var elapsed := 0.0

	while my_id == task_id and elapsed < start_time:
		display_screen.display_time(start_time - elapsed)
		await get_tree().create_timer(1.0).timeout
		elapsed += 1.0

	if my_id == task_id and player.direction != 0.0:
		display_screen.correct()
	elif my_id == task_id and player.direction == 0.0:
		await get_tree().create_timer(1.0).timeout
		display_screen.incorrect()

func _on_platform_area_body_exited(player: Player) -> void:
	display_screen.screen.color = Color.BLACK

	task_id += 1   # invalidate any running countdown loop
	await get_tree().create_timer(1.0).timeout
	display_screen.display_text(display_screen.text)
