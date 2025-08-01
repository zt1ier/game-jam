class_name Player extends CharacterBody2D


@export var speed: float = 400.0
@export var jump_height: float = -800.0
@export var air_control: float = 2.0
@export var friction: float = 2500.0
@export var max_fall_speed: float = 980.0


enum State { IDLE, WALKING, JUMPING, FALLING }

const STATE_NAMES := {
	State.IDLE: "IDLE",
	State.WALKING: "WALKING",
	State.JUMPING: "JUMPING",
	State.FALLING: "FALLING"
}

var current_state: State = State.IDLE
var direction: float = 0.0


@onready var main_anim: AnimatedSprite2D = $MainAnimationSprite
@onready var shadow_anim: AnimatedSprite2D = $DropShadowSprite
@onready var state_label: Label = $State/StateLabel


func _ready() -> void:
	if not is_in_group("Player"):
		add_to_group("Player")


func _physics_process(delta: float) -> void:
	if GameManager.intro_sequence:
		return

	direction = Input.get_axis("move_left", "move_right")

	match current_state:
		State.IDLE: _idle_state(delta)
		State.WALKING: _walking_state(delta)
		State.JUMPING: _jumping_state(delta)
		State.FALLING: _falling_state(delta)

	move_and_slide()

	# handle horizontal flipping
	if direction != 0:
		main_anim.flip_h = direction < 0
		shadow_anim.flip_h = direction < 0

	# visual stuff
	var state_name = STATE_NAMES.get(current_state, "IDLE")
	#state_label.text = state_name
	main_anim.play(state_name)
	shadow_anim.play(state_name)

	# transition logic
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			current_state = State.JUMPING
		elif abs(direction) > 0.01:
			current_state = State.WALKING
		else:
			current_state = State.IDLE
	else:
		current_state = State.FALLING


func _idle_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _walking_state(delta: float) -> void:
	velocity.x = move_toward(velocity.x, direction * speed, friction * delta)


func _jumping_state(delta: float) -> void:
	if is_on_floor():
		velocity.y = jump_height

	velocity.x = lerp(velocity.x, direction * speed, air_control * delta)


func _falling_state(delta: float) -> void:
	var fall_speed = lerp(velocity.y, get_gravity().y, air_control * delta)
	velocity.y = clamp(fall_speed, -INF, max_fall_speed)

	velocity.x = lerp(velocity.x, direction * speed, air_control * delta)
