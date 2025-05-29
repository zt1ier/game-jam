extends Node2D

@onready var player: CharacterBody2D = $"../Player"
@onready var rbc_scene: PackedScene = preload("res://scenes/red_blood_cell.tscn")
@onready var spawnpoint: Marker2D = $RBCSpawnMarker

@export var rbc_node_grp: Node2D

var health: int
var max_health: int = 100
var infected: bool = false

func _ready() -> void:
	health = max_health
	$SpawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	var rbc = rbc_scene.instantiate()
	if infected:
		player.infect_count += 1
		print("spawned infected")
		rbc._infected_rbc()
	rbc.global_position = spawnpoint.global_position
	rbc_node_grp.add_child(rbc)
	$SpawnTimer.start()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == player or body.is_in_group("infected"):
		_take_damage(body)

func _take_damage(body) -> void:
	health -= body.damage
	health = clamp(health, 0, max_health)
	if health == 0:
		infected = true
		$Sprite2D.modulate = Color("a10000")
		$HealthLabel.text = "Infected"
	else:
		$HealthLabel.text = str(health)
