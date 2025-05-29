extends Cell

@onready var infected_png: Texture2D = preload("res://purplecircle-removebg-preview.png")
@onready var infect_rad: Area2D = $InfectedDetection
@onready var infect_col: Area2D = $InfectedCollision
@onready var brain: Node2D = $"../../Brain"
@onready var heart: Node2D = $"../../Heart"
@onready var main: Node2D = $"../.."
@onready var player: CharacterBody2D = $"../../Player"

var escape_dir: Vector2
var escape_timer_value: float = 2.0
var escape_timer = escape_timer_value
var random_escape_speed: float = randf_range(0.7, 1.4)
var escape_speed_amplifier = speed_amplifier

var boss_battling = false
var brain_battle: bool = false
var heart_battle: bool = false

var rbc_speed = speed * 0.7
var attack_speed: float = rbc_speed * 1.5
var current_state = CELL_STATUS.HEALTHY

var chase_target: CharacterBody2D = null

var health: int = 5
var damage: int = 5
var current_color

func _ready() -> void:
	add_to_group("rbc")
	_cell_movement(1.0 / 60.0)
	infect_rad.monitoring = false
	infect_col.monitoring = false

func _physics_process(delta: float) -> void:
	
	current_color = $Sprite2D.modulate
	
	if Input.is_action_just_pressed("attack_brain") and current_state == CELL_STATUS.INFECTED:
		brain_battle = true
		boss_battling = true
	if Input.is_action_just_pressed("attack_heart") and current_state == CELL_STATUS.INFECTED \
		and not heart.infected:
		heart_battle = true
		boss_battling = true
	if Input.is_action_just_pressed("cancel_attack") and current_state == CELL_STATUS.INFECTED:
		boss_battling = false
		heart_battle = false
		brain_battle = false
	
	match current_state:
		CELL_STATUS.DEAD:
			player.infect_count -= 1
			player.infect_count = clamp(player.infect_count, 0, INF)
			_dead()
		CELL_STATUS.INFECTED:
			add_to_group("infected")
			remove_from_group("rbc")
			_move(delta)
			$InfectedDetection.monitoring = true
		CELL_STATUS.HEALTHY:
			$InfectedDetection.monitoring = false
			_move(delta)
		_:
			return

func _on_detection_collision_body_entered(body: CharacterBody2D) -> void:
	if body == player or body.is_in_group("infected"):
		escape_dir = (global_position - body.global_position).normalized() * random_escape_speed
		escape_timer = escape_timer_value

func _handle_wall_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	if collider is StaticBody2D:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal).normalized() * speed

func _move(delta) -> void:
	if brain_battle:
		_boss_battle(brain.global_position)
	elif heart_battle:
		_boss_battle(heart.global_position)
		return
	
	if escape_dir != Vector2.ZERO:
		velocity = velocity.lerp(escape_dir * speed * random_escape_speed, delta * escape_speed_amplifier)
		
		escape_timer -= delta
		if escape_timer <= 0.0:
			escape_dir = Vector2.ZERO
	else:
		_cell_movement(delta, rbc_speed)
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		_handle_wall_collision(collision)
	
	if current_state == CELL_STATUS.INFECTED:
		_chasing()

func _infected_rbc() -> void:
	add_to_group("infected")
	remove_from_group("rbc")
	current_state = CELL_STATUS.INFECTED
	$Sprite2D.modulate = Color("7020f0")
	if is_instance_valid(self):
		$InfectedDetection.monitoring = true
		$InfectedCollision.monitoring = true
		if main:
			main.total_infected += 1

func _on_infected_detection_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("rbc") and body.current_state == CELL_STATUS.HEALTHY:
		chase_target = body
	elif body.is_in_group("wbc") and chase_target == null:
		chase_target = body

func _chasing() -> void:
	if brain_battle:
		_boss_battle(brain.global_position)
	elif heart_battle and not heart.infected:
		_boss_battle(heart.global_position)
		return
	
	if is_instance_valid(chase_target):
		if chase_target.is_in_group("rbc") and chase_target.current_state == CELL_STATUS.HEALTHY:
			var dir = (chase_target.global_position - global_position).normalized()
			velocity = dir * (rbc_speed * 1.05)
		elif chase_target.is_in_group("wbc"):
			var dir = (chase_target.global_position - global_position).normalized()
			velocity = dir * rbc_speed
		move_and_slide()
	else:
		chase_target = null

func _on_infected_detection_body_exited(body: CharacterBody2D) -> void:
	if body == chase_target:
		chase_target = null

func _on_infected_collision_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("rbc") and body.current_state == CELL_STATUS.HEALTHY and body != self:
		player.infect_count += 1
		print("rbc attacked")
		body._infected_rbc()

func _take_damage(body) -> void:
	health -= body.damage
	if health <= 0:
		current_state = CELL_STATUS.DEAD

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("wbc") and current_state == CELL_STATUS.INFECTED:
		_take_damage(body)
		body._take_damage(self)

func _boss_battle(target_pos: Vector2) -> void:
	if target_pos == heart.global_position:
		velocity = (target_pos - global_position).normalized() * rbc_speed * 1.5
	elif target_pos == brain.global_position:
		velocity = (target_pos - global_position).normalized() * rbc_speed * 0.5
	move_and_slide()
	boss_battling = true
	if global_position.distance_to(target_pos) < 250:
		_attack_boss()

func _attack_boss() -> void:
	velocity = Vector2.ZERO
	var start_pos = global_position
	
	await get_tree().create_timer(0.5).timeout
	
	if is_instance_valid(chase_target):
		var target_pos = chase_target.global_position
		var attack_dir = (target_pos - start_pos).normalized()
		
		velocity = attack_dir * attack_speed
		move_and_slide()
	
	velocity = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	
	var return_dir = (start_pos - global_position).normalized()
	var return_speed = rbc_speed
	
	velocity = return_dir * return_speed
	move_and_slide()
	await get_tree().process_frame
	
	velocity = Vector2.ZERO
