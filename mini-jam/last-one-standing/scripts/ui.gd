class_name HUD
extends CanvasLayer


var label_shake_strength: float = 0.0
var label_shake_decay: float = 30.0
var label_initial_position: Vector2


var warning_label: Label
var confirm_label: Label

var warning_sfx: AudioStreamPlayer


func _ready() -> void:
	add_to_group("UI")


func selected_warning() -> void:
	warning_label.show()
	shake_label()
	warning_sfx.play()
	await get_tree().create_timer(1).timeout
	warning_label.hide()


func shake_label() -> void:
	if warning_label:
		label_initial_position = warning_label.position
		label_shake_strength = 5.0


func _physics_process(delta: float) -> void:
	if confirm_label:
		if NumberValues.numbers.size() >= 2:
			confirm_label.show()
		else:
			confirm_label.hide()
	
	if warning_label and label_shake_strength > 0.0:
		var offset := Vector2(
			randf_range(-label_shake_strength, label_shake_strength),
			randf_range(-label_shake_strength, label_shake_strength)
		)
		
		warning_label.position = label_initial_position + offset
		label_shake_strength = max(label_shake_strength - label_shake_decay * delta, 0)
	elif warning_label:
		label_initial_position.y = 240
		warning_label.position = label_initial_position
