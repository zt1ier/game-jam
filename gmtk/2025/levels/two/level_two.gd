class_name LevelTwo extends Level


var glow_interval: float = 0.0

var hint_time: float = 0.0
var hint_time_threshold: float = 20.0

var near_button_proximity: bool = false
var glowing: bool = false


@onready var button: AnimatedSprite2D = $Button/ButtonSprite


func _ready() -> void:
	super()
	button.play("DIM")
	start_glow_timer()


func _physics_process(delta: float) -> void:
	if not near_button_proximity:
		return

	if Input.is_action_just_pressed("interact"):
		if glowing:
			_button_pressed()
		else:
			display_screen.correct()

	if near_button_proximity:
		hint_time += delta
		if hint_time >= hint_time_threshold:
			display_screen.incorrect("Press E to interact.")


func _button_pressed() -> void:
	glowing = false
	button.play("DIM")
	start_glow_timer()


func start_glow_timer() -> void:
	glow_interval = randf_range(3.0, 10.0)
	await get_tree().create_timer(glow_interval).timeout
	glowing = true
	button.play("GLOW")


func _on_button_body_entered(_body: Player) -> void:
	near_button_proximity = true


func _on_button_body_exited(_body: Player) -> void:
	near_button_proximity = false
