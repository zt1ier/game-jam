extends Cell

@onready var player: CharacterBody2D = $"../../Player"
@onready var detect_rad: Area2D = $DetectInfectedRadius
@onready var detect_ray: RayCast2D = $DetectPlayerRaycast
@onready var main: Node2D = $"../.."
@onready var brain: Node2D = $"../../Brain"

var max_health: int = 10
var damage: int = 5
var health: int

var boss_battling: bool = false

var wbc_speed: float = speed * 0.8
var init_speed: float = wbc_speed

var attack_range: float = 75.0
var attack_speed: float = wbc_speed * 1.7
var current_state = CELL_STATUS.HEALTHY

var infected_cells: Array = []
var chase_target: CharacterBody2D = null

var is_boosted: bool = false

func _ready() -> void:
	add_to_group("wbc")
	health = max_health

func _physics_process(delta: float) -> void:
	if health <= 0:
		remove_from_group("wbc")
		queue_free()
	
	#if current_state == CELL_STATUS.INFECTED:
		#_chasing()
	
	if not main.game_running or main.game_victory:
		detect_rad.monitoring = false
		detect_ray.enabled = false
	else:
		detect_rad.monitoring = true
		detect_ray.enabled = true
	
	_update_target()
	_chase_target(delta)
	move_and_slide()

func _update_target() -> void:
	detect_ray.look_at(player.global_position)
	
	if current_state == CELL_STATUS.HEALTHY:
		if detect_ray.is_colliding() and detect_ray.get_collider() == player:
			chase_target = player
		elif infected_cells.size() > 0:
			chase_target = _find_closest_infected()
		else:
			chase_target = null
	#elif current_state == CELL_STATUS.INFECTED:
		#var target = _find_closest_healthy_wbc()
		#if target:
			#chase_target = target
		#else:
			#chase_target = null

func _chase_target(delta: float) -> void:
	if chase_target:
		var dist = global_position.distance_to(chase_target.global_position)
		if dist < attack_range and current_state == CELL_STATUS.HEALTHY:
			_attack_target(delta)
		elif dist < attack_range and current_state == CELL_STATUS.INFECTED:
			_infect_target()
		else:
			velocity = (chase_target.global_position - global_position).normalized() * wbc_speed * 1.4
	else:
		_cell_movement(delta, wbc_speed * 0.7)

func _attack_target(delta) -> void:
	if main:
		if main.fever_mode:
			velocity = (chase_target.global_position - global_position).normalized() * wbc_speed
		else:
			velocity = Vector2.ZERO
			var start_pos = global_position
			
			await get_tree().create_timer(0.5).timeout
			
			if is_instance_valid(chase_target):
				var target_pos = chase_target.global_position
				var attack_dir = (target_pos - start_pos).normalized()
				
				velocity = attack_dir * attack_speed * delta * 50
				move_and_slide()
			
			velocity = Vector2.ZERO
			await get_tree().create_timer(1).timeout
			
			var return_dir = (start_pos - global_position).normalized()
			
			velocity = return_dir * attack_speed * delta * 100
			move_and_slide()
			await get_tree().process_frame
			
			velocity = Vector2.ZERO

func _find_closest_infected() -> CharacterBody2D:
	var nearest = null
	var min_dist = INF
	
	for infected in infected_cells:
		if infected.is_inside_tree():
			var dist = global_position.distance_to(infected.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = infected
	
	return nearest

func _take_damage(body) -> void:
	health -= body.damage

func _on_detect_infected_radius_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("infected") and body != self:
		infected_cells.append(body)

func _on_detect_infected_radius_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("infected") and body != self:
		infected_cells.erase(body)

func _infect_wbc() -> void:
	current_state = CELL_STATUS.INFECTED
	add_to_group("infected")
	$Sprite2D.modulate = Color("E6E6FA")
	wbc_speed *= 1.2

func _chasing() -> void:
	if boss_battling:
		_boss_battle()
		return
	
	if is_instance_valid(chase_target):
		if chase_target.is_in_group("rbc") and chase_target.current_state == CELL_STATUS.HEALTHY:
			var new_dir = (chase_target.global_position - global_position).normalized()
			velocity = new_dir * (wbc_speed * 1.05)
		elif chase_target.is_in_group("wbc"):
			var new_dir = (chase_target.global_position - global_position).normalized()
			velocity = new_dir * wbc_speed
		move_and_slide()
	else:
		chase_target = null

func _boss_battle(target_pos: Vector2 = brain.global_position) -> void:
	velocity = (target_pos - global_position).normalized() * speed * 1.7
	move_and_slide()
	boss_battling = true

func _find_closest_healthy_wbc() -> CharacterBody2D:
	var nearest = null
	var min_dist = INF
	
	for wbc in get_tree().get_nodes_in_group("wbc"):
		if wbc.is_inside_tree() and wbc.current_state == CELL_STATUS.HEALTHY:
			var dist = global_position.distance_to(wbc.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = wbc
	
	return nearest

func _infect_target() -> void:
	if chase_target and chase_target.current_state == CELL_STATUS.HEALTHY:
		chase_target._infect_wbc()
		chase_target = null
