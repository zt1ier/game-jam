class_name LevelThree extends Level


@export var dirt_level: int = 3 # 0 = clean, 4 = max dirty


var completed_timer: float = 0.0
var completed_threshold: float = 2.0
var complete: bool = false

var jar_active: bool = false

var scrub_progress: float = 0.0
var scrub_threshold: float = 100.0

var last_mouse_pos: Vector2 = Vector2.ZERO
var can_scrub: bool = false

var jar_spread_timer: float = 0.0
var jar_spread_interval: float = 4.0   # spread interval in seconds, speeds up

var spread_active: bool = false
var near_button_proximity: bool = false


@onready var sprite: AnimatedSprite2D = $Jar/Sprite

@onready var jar_camera: Camera2D = $JarCamera
@onready var scrub_bar: ProgressBar = $JarCamera/ScrubBar


func _ready() -> void:
	if jar_camera.enabled:
		jar_camera.enabled = false
		scrub_bar.hide()
	_update_dirt_level()
	super()


func _physics_process(delta: float) -> void:
	if jar_active:
		_handle_scrubbing()
		_handle_spread(delta)

		if dirt_level == 4:
			completed_timer += get_process_delta_time()
			if completed_timer >= completed_threshold and not complete:
				_level_complete()
		else:
			completed_timer = 0.0

	if not near_button_proximity:
		return

	if Input.is_action_just_pressed("interact"):
		if not jar_camera.enabled:
			_enter_jar_ui()
		else:
			_exit_jar_ui()


func _handle_scrubbing() -> void:
	if not can_scrub or dirt_level <= 0:
		return

	var current_mouse_pos := get_viewport().get_mouse_position()
	var movement := (current_mouse_pos - last_mouse_pos).length() / 100
	last_mouse_pos = current_mouse_pos

	scrub_progress += movement
	scrub_bar.value = (scrub_progress / scrub_threshold) * 100.0

	if scrub_progress >= scrub_threshold:
		dirt_level -= 1
		_update_dirt_level()
		scrub_progress = 0.0
		scrub_bar.value = 0.0
		jar_spread_interval = _get_spread_interval_for_level(dirt_level)

	if dirt_level == 4:
		_level_complete()
	else:
		completed_timer = 0.0


func _handle_spread(delta: float) -> void:
	if not spread_active or dirt_level >= 4:
		return

	jar_spread_timer += delta
	if jar_spread_timer >= jar_spread_interval:
		jar_spread_timer = 0.0
		dirt_level += 1
		_update_dirt_level()


func _enter_jar_ui() -> void:
	jar_active = true
	jar_camera.enabled = true
	scrub_bar.show()
	can_scrub = true
	last_mouse_pos = get_viewport().get_mouse_position()
	scrub_progress = 0.0
	scrub_bar.value = 0.0

	if not spread_active:
		_start_jar_spread()


func _exit_jar_ui() -> void:
	jar_camera.enabled = false
	scrub_bar.hide()
	can_scrub = false
	scrub_progress = 0.0
	scrub_bar.value = 0.0
	

func _start_jar_spread() -> void:
	spread_active = true
	jar_spread_timer = 0.0


func _update_dirt_level() -> void:
	dirt_level = clamp(dirt_level, 0, 4)
	sprite.frame = dirt_level
	print(dirt_level)


func _level_complete() -> void:
	if complete: 
		return
	complete = true
	display_screen.correct()


func _get_spread_interval_for_level(level: int) -> float:
	match level:
		0: return 1.0  # fastest spread when fully clean
		1: return 1.5
		2: return 2.5
		3: return 4.0
		_: return 5.0  # slowest spread at dirtiest


func _on_jar_body_entered(_body: Player) -> void:
	near_button_proximity = true


func _on_jar_body_exited(_body: Player) -> void:
	near_button_proximity = false
