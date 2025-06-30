class_name Gobbo extends CharacterBody2D


# default movement
const SPEED: float = 400.0
const JUMP_VELOCITY: float = -1000.0
const AIR_CONTROL: float = 2.0
const FRICTION: float = 2000.0

# platformer polish
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.1

# state label debugging
const STATE_NAMES = {
	State.IDLE: "IDLE",
	State.MOVING: "MOVING",
	State.JUMPING: "JUMPING",
	State.FALLING: "FALLING",
}


# states declaration
enum State {
	IDLE,
	MOVING,
	JUMPING,
	FALLING,
}


var state: State = State.IDLE
var direction: float = 0.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0


@onready var state_label: Label = $StateLabel


func _ready() -> void:
	add_to_group("Gobbo")


func _physics_process(delta: float) -> void:
	# directional movement input
	direction = Input.get_axis("move_left", "move_right")

	# update timers
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# process states
	match state:
		State.IDLE: _process_idle(delta)
		State.MOVING: _process_moving(delta)
		State.JUMPING: _process_jumping(delta)
		State.FALLING: _process_falling(delta)

	state_label.text = STATE_NAMES.get(state, "UNKNOWN")

	move_and_slide()

	# transition states
	if is_on_floor():
		if jump_buffer_timer > 0.0:
			jump_buffer_timer = 0.0
			state = State.JUMPING
		elif direction != 0.0:
			state = State.MOVING
		else:
			state = State.IDLE
	else:
		if coyote_timer > 0.0 and Input.is_action_just_pressed("jump"):
			state = State.JUMPING
		else:
			state = State.FALLING


func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)


func _process_moving(delta: float) -> void:
	velocity.x = move_toward(velocity.x, direction * SPEED, FRICTION * delta)


func _process_jumping(delta: float) -> void:
	velocity.y = JUMP_VELOCITY

	# give gradual air control, but preserve primary directional momentum
	velocity.x = lerp(velocity.x, direction * SPEED, AIR_CONTROL * delta)


func _process_falling(delta: float) -> void:
	var fall_speed = lerp(velocity.y, get_gravity().y * 1.35, AIR_CONTROL * delta)
	velocity.y = fall_speed

	# give gradual air control, but preserve primary directional momentum
	velocity.x = lerp(velocity.x, direction * SPEED, AIR_CONTROL * delta)
