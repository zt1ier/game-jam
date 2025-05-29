extends Cell

@onready var death_ui: CanvasLayer = $GameOverScreen
@onready var main: Node2D = $".."

var infect_count: int = 0
var current_state = CELL_STATUS.INFECTED

var player_speed: float = speed * 1.4
var health: int = 20
var damage: int = 5
var init_speed: float = player_speed
var run_speed: float = player_speed * 1.2

var took_damage: bool = false

func _ready() -> void:
	death_ui.hide()
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if health <= 0:
		death_ui.show()
		return
	
	var dir = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = dir * player_speed
	move_and_slide()
	
	if Input.is_action_pressed("run"):
		if not main.fever_mode:
			player_speed = run_speed
		if dir != Vector2.ZERO:
			main.heat += 1 * delta
			main.heat = clampf(main.heat, 0, main.max_heat)
	else:
		if dir != Vector2.ZERO: # if moving but not running, slower heat decrease
			main.heat -= 0.5 * delta
		else: # if not moving, faster heat decrease
			main.heat -= 1 * delta
		main.heat = clampf(main.heat, 0, main.max_heat)
		player_speed = init_speed
	
	if took_damage:
		#camera_shake()
		pass

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("wbc") and not took_damage:
		_take_damage(body)

func _take_damage(body) -> void:
	took_damage = true
	health -= body.damage
	health = clamp(health, 0, 50)
	await get_tree().create_timer(0.5).timeout
	took_damage = false

func _on_infection_collision_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("rbc") and body.current_state == CELL_STATUS.HEALTHY:
		infect_count += 1
		print("player attacked")
		body._infected_rbc()

func camera_shake():
	var camera_shake_interval: int = 2
	var tween = create_tween()
	for i in range(camera_shake_interval):
		tween.tween_property($Camera2D, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.02)
		tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.02)

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
