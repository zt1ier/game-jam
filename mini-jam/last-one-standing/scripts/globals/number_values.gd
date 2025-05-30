extends Node


const MAX_NUMBERS: int = 4


var numbers: Array = []
var operations: Array = []

var result: int = 0

var selected_enemies: Array[Enemy] = []

var shaking_labels: Dictionary = {}


var label: Label
var label_shake_strength: float = 0.0
var label_shake_decay: float = 30.0
var label_initial_position: Vector2

var zero_hint_label: Label


var c_sfx: AudioStreamPlayer
var i_sfx: AudioStreamPlayer

var warning_sfx: AudioStreamPlayer


func reset_values() -> void:
	if label:
		label.modulate = Color.WHITE
	
	numbers.clear()
	operations.clear()


func update_label() -> void:
	if label:
		label.modulate = Color.WHITE
		if numbers.is_empty():
			label.text = "_ _ _"
		else:
			var text = str(numbers[0])
			for i in range(1, numbers.size()):
				text += " " + operations[i - 1] + " " + str(numbers[i])
			label.text = text + " = " + str(get_current_partial_sum())


func confirm() -> void:
	if numbers.size() < 2:
		print("Not enough numbers!")
		return
	
	var result = numbers[0]
	for i in range(1, numbers.size()):
		var op = operations[i - 1]
		var num = numbers[i]
		
		if op == "+":
			result += num
		elif op == "-":
			result -= num
	
	print("Result: %d" % result)
	
	if result == 0:
		for enemy in selected_enemies:
			enemy.on_death()
		
		if has_method("correct"):
			PointsHandler.combo_multiplier += 1
			correct()
	else:
		if has_method("incorrect"):
			PointsHandler.combo_multiplier = 1
			incorrect()
	
	for enemy in selected_enemies:
		enemy.selected = false
	
	selected_enemies.clear()


func get_current_partial_sum() -> int:
	if numbers.is_empty():
		return 0
	
	var partial_sum = numbers[0]
	for i in range(1, numbers.size()):
		var op = operations[i - 1]
		var num = numbers[i]
		
		if op == "+":
			partial_sum += num
		elif op == "-":
			partial_sum -= num
	
	return partial_sum


func correct() -> void:
	PointsHandler.points += 1 * PointsHandler.combo_multiplier
	reset_values()
	
	if label:
		label.modulate = Color.GREEN
	
	c_sfx.pitch_scale = randf_range(0.9, 1)
	c_sfx.play()
	
	await get_tree().create_timer(1).timeout
	update_label()


func incorrect() -> void:
	reset_values()
	
	if label:
		label.modulate = Color.RED
		shake_label(label)
	
	if zero_hint_label:
		zero_hint_label.show()
		shake_label(zero_hint_label)
		warning_sfx.play()
	
	i_sfx.pitch_scale = randf_range(0.5, 1)
	i_sfx.play()
	
	await get_tree().create_timer(1).timeout
	zero_hint_label.hide()
	update_label()


func shake_label(text_label: Label) -> void:
	if text_label and not shaking_labels.has(text_label):
		shaking_labels[text_label] = {
			"init_pos": text_label.global_position,
			"shake_strength": 5.0,
		}


func _physics_process(delta: float) -> void:
	for label in shaking_labels.keys():
		var value = shaking_labels[label]
		var offset = Vector2(
			randf_range(-value["shake_strength"], value["shake_strength"]),
			randf_range(-value["shake_strength"], value["shake_strength"])
		)
		
		label.position = value["init_pos"] + offset
		
		value["shake_strength"] = max(value["shake_strength"] - label_shake_decay * delta, 0)
		
		shaking_labels[label] = value
		
		if value["shake_strength"] <= 0.0:
			label.position = value["init_pos"]
			shaking_labels.erase(label)
