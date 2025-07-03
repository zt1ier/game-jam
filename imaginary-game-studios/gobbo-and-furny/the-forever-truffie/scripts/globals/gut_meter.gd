extends Node


var max_pressure: float = 10.0
var gut_pressure: float = 5.0

var first_digest: bool = true
var first_reject: bool = true

var dialogue_tree: DialogueTree


func refresh() -> void:
	gut_pressure = 5.0


func digest() -> void:
	gut_pressure = clamp(gut_pressure - 1.0, 0.0, max_pressure)

	if first_digest:
		dialogue_tree.show_dialogue(GameState.current_level, "first_wrong")
		first_digest = false


func reject() -> void:
	gut_pressure = clamp(gut_pressure + 1.0, 0.0, max_pressure)

	if first_reject:
		dialogue_tree.show_dialogue(GameState.current_level, "first_wrong")
		first_reject = false

	if gut_pressure == max_pressure:
		GameState.game_lost.emit()
	
