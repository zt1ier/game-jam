class_name Furny extends CharacterBody2D


@export var speed: float = 500.0


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("Furny")


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed
	move_and_slide()

	_handle_animation(direction)


func _handle_animation(direction: Vector2) -> void:
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true

	if direction != Vector2.ZERO:
		anim.play("walk")
	else:
		anim.play("RESET")
