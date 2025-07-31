# this is THE 2D player controller (no coyote or buffer)
class_name Player extends CharacterBody2D


@export var speed: float = 400.0
@export var jump_height: float = -800.0
@export var air_control: float = 2.0
@export var friction: float = 2000.0

@export var max_fall_speed: float = 980.0


# state label debugging
const STATE_NAMES = {
	State.IDLE: "IDLE",
	State.MOVING: "MOVING",
	State.JUMPING: "JUMPING",
	State.FALLING: "FALLING",
}


enum State {
	IDLE, # 0
	MOVING, # 1
	JUMPING, # 2
	FALLING, # 3
}


var current_state: State = State.IDLE

var direction: float = 0.0


@onready var state_label: Label = $StateLabel


func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")

	match current_state:
		State.IDLE: _idle_state(delta)
		State.MOVING: _moving_state(delta)
		State.JUMPING: _jumping_state(delta)
		State.FALLING: _falling_state(delta)

	move_and_slide()

	state_label.text = STATE_NAMES.get(current_state, "idk")

	# update states
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			current_state = State.JUMPING
		elif direction != 0.0:
			current_state = State.MOVING
		else:
			current_state = State.IDLE
	else:
		if velocity.y < 0.0:
			current_state = State.JUMPING
		else:
			current_state = State.FALLING

	print(current_state)


func _idle_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _moving_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, direction * speed, friction * delta)


func _jumping_state(delta: float) -> void:
	if is_on_floor():
		velocity.y = jump_height

	# give gradual air control, but preserve primary directional momentum
	velocity.x = lerp(velocity.x, direction * speed, air_control * delta)


func _falling_state(delta: float) -> void:
	var fall_speed = lerp(velocity.y, get_gravity().y, air_control * delta)
	velocity.y = clamp(fall_speed, -INF, max_fall_speed)

	# give gradual air control, but preserve primary directional momentum
	velocity.x = lerp(velocity.x, direction * speed, air_control * delta)
