class_name Cell
extends CharacterBody2D

@export var speed: float = 200.0
@export var speed_amplifier: float = 7.0

enum CELL_STATUS {HEALTHY, INFECTED, DEAD}

var dir: Vector2
var change_dir_time: float = 0.0

func _ready() -> void:
	dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _cell_movement(delta: float, speed: float = speed):
	change_dir_time -= delta
	if change_dir_time <= 0:
		dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		change_dir_time = randf_range(0.7, 1.2)
	
	velocity = velocity.lerp(dir * speed, delta * speed_amplifier)
	move_and_slide()

func _infected():
	pass

func _dead():
	remove_from_group("rbc")
	queue_free()
