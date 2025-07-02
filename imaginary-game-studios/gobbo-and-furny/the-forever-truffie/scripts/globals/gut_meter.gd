extends Node


var max_pressure: float = 10.0
var gut_pressure: float = 5.0


func refresh() -> void:
	gut_pressure = 5.0


func digest() -> void:
	gut_pressure = clamp(gut_pressure - 1.0, 0.0, max_pressure)


func reject() -> void:
	gut_pressure = clamp(gut_pressure + 1.0, 0.0, max_pressure)
	if gut_pressure == max_pressure:
		GameState.game_lost.emit()
