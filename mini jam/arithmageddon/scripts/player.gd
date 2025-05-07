class_name Player
extends CharacterBody2D


const BULLET_SCENE = preload("res://scenes/bullet.tscn")


@export_subgroup("Parameters")
@export var speed: float = 200.0
@export var current_operation: Operation


var operation_index: int = 0 ## default to addition
var combo_multiplier: int = PointsHandler.combo_multiplier

var dead: bool = false

var walk_timer: float = 0.0
var base_text: String

var operations: Array = [
	preload("res://scripts/operations/addition.tres"), ## ADDITION
	preload("res://scripts/operations/subtraction.tres"), ## SUBTRACTION
	#preload("res://scripts/operations/multiplication.tres"), ## MULTIPLICATION
	#preload("res://scripts/operations/division.tres"), ## DIVISION
]


@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawnpoint: Marker2D = $BulletSpawnpoint
@onready var operation_label: Label = $"../UI/OperationLabel"
@onready var loss_label: Label = $LossLabel
@onready var ui: HUD = $"../UI"
@onready var main_menu: Button = $LossLabel/MainMenu



func _ready() -> void:
	add_to_group("Player")
	
	if not current_operation:
		current_operation = operations[operation_index] ## default to addition
	
	base_text = main_menu.text


func _physics_process(_delta: float) -> void:
	if dead:
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	handle_animation(direction)
	
	velocity = direction * speed
	move_and_slide()
	
	handle_aim()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("confirm"):
		NumberValues.confirm()
	
	if Input.is_action_just_pressed("operation_left"):
		$ShiftSFX.pitch_scale = randf_range(1.5, 2.0)
		$ShiftSFX.play()
		operation_index = (operation_index - 1) % operations.size()
		current_operation = operations[operation_index]
	elif Input.is_action_just_pressed("operation_right"):
		
		operation_index = (operation_index + 1) % operations.size()
		current_operation = operations[operation_index]
	
	if current_operation.icon == "+":
		operation_label.text = "+"
	elif current_operation.icon == "-":
		operation_label.text = "-"


func handle_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		animation.play("movement")
		
		walk_timer -= get_physics_process_delta_time()
		if walk_timer <= 0.0:
			$WalkSFX.pitch_scale = randf_range(0.8, 1.2)
			$WalkSFX.play()
			walk_timer = 0.5
	else:
		animation.play("idle")
		$WalkSFX.stop()
		walk_timer = 0.0


func handle_aim() -> void:
	var target_position := (get_global_mouse_position() - global_position).normalized()
	bullet_spawnpoint.position = target_position


func shoot() -> void:
	$ShootSFX.pitch_scale = randf_range(0.5, 1.5)
	$ShootSFX.play()
	
	var bullet := BULLET_SCENE.instantiate()
	bullet.operation = current_operation
	bullet.direction = bullet_spawnpoint.position
	bullet.global_position = bullet_spawnpoint.global_position
	bullet.global_rotation = global_rotation
	add_sibling(bullet)


func _on_hurtbox_body_entered(body: Enemy) -> void:
	dead = true
	NumberValues.reset_values()
	
	loss_label.show()
	
	for enemy in NumberValues.selected_enemies:
		enemy.selected = false
	NumberValues.selected_enemies.clear()
	
	ui.hide()


func _on_main_menu_mouse_entered() -> void:
	main_menu.text = "▮ " + base_text


func _on_main_menu_mouse_exited() -> void:
	main_menu.text = base_text
