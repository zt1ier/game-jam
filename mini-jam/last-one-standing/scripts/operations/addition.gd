extends Node


func calculate(enemy: Enemy, operation: Operation) -> void:
	if NumberValues.selected_enemies.has(enemy):
		print("Can't select the same enemy.")
		HeadsUpDisplay.selected_warning()
		return
	
	if NumberValues.numbers.size() >= NumberValues.MAX_NUMBERS:
		print("Reached maximum numbers.")
		return
	
	enemy.selected_color(Color.GREEN)
	enemy.selected = true
	
	if NumberValues.numbers.is_empty():
		NumberValues.numbers.append(enemy.number)
	else:
		NumberValues.operations.append(operation.icon)
		NumberValues.numbers.append(enemy.number)
	
	NumberValues.selected_enemies.append(enemy)
	NumberValues.update_label()
