class_name Furny extends CharacterBody2D


@export var speed: float = 400.0


var lerp_speed: float = 7.0


@onready var gut_meter: ProgressBar = $"../GutMeter"


func _ready() -> void:
	add_to_group("Furny")

	if gut_meter == null:
		gut_meter = get_tree().get_first_node_in_group("GutMeter") as ProgressBar


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed
	move_and_slide()

	gut_meter.value = lerp(gut_meter.value, float(GutMeter.gut_value), delta * lerp_speed)
