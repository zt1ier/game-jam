class_name Enemy
extends CharacterBody2D


const DEATH_PARTICLES = preload("res://scenes/death_particles.tscn")


@export_subgroup("Parameters")
@export var speed: float = 100.0


var amplifier: float = 1.0

var random_number: int
var number: int

var selected: bool = false

var repulsion_radius: float = 25.0


@onready var label: Label = $Number
@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	add_to_group("Enemy")
	
	animation.play("movement")
	
	roll_number()
	
	update_label()


func roll_number() -> void:
	while true:
		random_number = randi_range(-20, 20)
		if random_number != -1 or random_number != 0 or random_number != 1:
			break
	number = random_number


func speed_amplifier() -> void:
	var amp = abs(number)
	amplifier = 1.0 + (amp / 100.0)


func _draw() -> void:
	## REPULSION DEBUG
	#draw_circle(Vector2.ZERO, repulsion_radius, Color.RED, false)
	pass


func _physics_process(_delta: float) -> void:
	handle_movement()
	speed_amplifier()
	
	if selected:
		label.add_theme_constant_override("outline_size", 3)
	else:
		label.remove_theme_constant_override("outline_size")


func handle_movement() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	var move_direction := (player.global_position - global_position).normalized()
	var base_velocity = move_direction * speed * amplifier
	
	var enemies := get_tree().get_nodes_in_group("Enemy")
	var repulsion_force := Vector2.ZERO
	
	for other_enemy in enemies:
			if other_enemy != self:
				var offset = (global_position - other_enemy.global_position).normalized()
				var distance = offset.length()
				if distance > 0 and distance < repulsion_radius:
					repulsion_force += offset * ((repulsion_radius - distance) / repulsion_radius)
	
	velocity = base_velocity + (repulsion_force * 25.0)
	move_and_slide()


func update_label() -> void:
	label.text = str(number)


func selected_color(color: Color) -> void:
	label.add_theme_color_override("font_outline_color", color)


func on_death() -> void:
	var particles := DEATH_PARTICLES.instantiate()
	particles.global_position = global_position + (label.size / 2)
	particles.one_shot = true
	particles.emitting = true
	add_sibling(particles)
	
	$DeathSFX.pitch_scale = randf_range(1, 2)
	$DeathSFX.play()
	
	await get_tree().create_timer(0.01).timeout
	queue_free()
