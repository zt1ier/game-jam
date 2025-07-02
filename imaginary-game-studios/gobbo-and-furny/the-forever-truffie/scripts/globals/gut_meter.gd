extends Node


var gut_value: int = 5


func refresh() -> void:
	gut_value = 5


func digest() -> void:
	gut_value += 1


func reject() -> void:
	gut_value -= 1
