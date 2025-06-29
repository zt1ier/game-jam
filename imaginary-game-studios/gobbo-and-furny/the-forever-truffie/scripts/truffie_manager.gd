extends Node


signal meter_changed


var truffie_meter: float = 20


func _physics_process(delta: float) -> void:
	decrease_meter_over_time(delta)


func increase_meter(amount: float) -> void:
	if truffie_meter < 50:
		truffie_meter += amount
		meter_changed.emit()


func decrease_meter_over_time(delta: float) -> void:
	truffie_meter -= delta * 0.25
	print(truffie_meter)
	meter_changed.emit()
