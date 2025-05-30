extends Node2D

@onready var player: CharacterBody2D = $"../Player"
@onready var wbc_scene: PackedScene = preload("res://scenes/white_blood_cell.tscn")
@onready var spawnpoint: Marker2D = $WBCSpawnMarker
@onready var spawn_timer: Timer = $SpawnTimer

@export var wbc_node_grp: Node2D

var max_health: int = 100
var health: int

func _ready() -> void:
	health = max_health
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	var wbc = wbc_scene.instantiate()
	wbc.global_position = spawnpoint.global_position
	wbc_node_grp.add_child(wbc)
	spawn_timer.start()

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("infected") or body == player:
		_take_damage(body)

func _take_damage(body):
	health -= body.damage
	health = clamp(health, 0, max_health)
	if health == 0:
		$Sprite2D.modulate = Color("b10074")
		$HealthLabel.text = "Infected"
	else:
		$HealthLabel.text = str(health)
