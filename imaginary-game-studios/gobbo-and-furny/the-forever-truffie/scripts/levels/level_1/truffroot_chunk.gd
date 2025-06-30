class_name TruffrootChunk extends StaticBody2D


signal done_falling


@export var hover_position: Vector2 = Vector2.ZERO
@export var hover_duration: float = 2.5

@export var fall_gravity: float = 1000.0
@export var max_fall_speed: float = 1750.0
@export var initial_fall_delay: float = 1.5

@export var hover_bob_amp: float = 4.0
@export var hover_bob_speed: float = 6.0


enum State {
	WAITING,
	FALLING_TO_HOVER,
	HOVERING,
	FALLING_FINAL,
}


var state: State = State.WAITING
var fall_speed: float = 0.0

var hover_timer: float = 0.0
var hover_bob: float = 0.0
var base_y: float = 0.0


@onready var collision: CollisionShape2D = $CollisionShape2D


func reset(hover_pos: Vector2) -> void:
	hover_position = hover_pos
	position = Vector2(hover_position.x, -500)

	initial_fall_delay += randf_range(-0.1, 0.2)

	state = State.WAITING

	fall_speed = 0.0
	hover_bob = 0.0
	base_y = 0.0

	collision.disabled = false
	hide()

	await get_tree().create_timer(initial_fall_delay).timeout

	state = State.FALLING_TO_HOVER
	show()


func _physics_process(delta: float) -> void:
	match state:
		State.FALLING_TO_HOVER:
			fall_speed = min(fall_speed + fall_gravity * delta, max_fall_speed)
			position.y += fall_speed * delta

			if position.y >= hover_position.y:
				position.y = hover_position.y
				base_y = position.y
				hover_timer = hover_duration
				fall_speed = 0.0
				hover_bob = 0.0
				state = State.HOVERING

		State.HOVERING:
			hover_timer -= delta
			_hover_bobbing(delta)
			if hover_timer <= 0.0:
				state = State.FALLING_FINAL
				collision.disabled = false
				position.y = base_y

		State.FALLING_FINAL:
			fall_speed = min(fall_speed + fall_gravity * delta, max_fall_speed)
			position.y += fall_speed * delta


func _hover_bobbing(delta: float) -> void:
	hover_bob += delta
	position.y = base_y + sin(hover_bob * hover_bob_speed) * hover_bob_amp


func _on_screen_exited() -> void:
	hide()
	state = State.WAITING

	fall_speed = 0.0
	collision.disabled = true

	done_falling.emit()
