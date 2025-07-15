class_name Manifestation extends Node3D


@export var stage_name: String = "" # stage of grief
@export var hunt_location: int = 0 # matches LookingAt index
@export var attack_threshold: float = 5.0 # seconds before it attacks
@export var cooldown_time: float = 3.0 # seconds to wait before restarting hunt
@export var active_day: int = 1 # day it begins appearing


var _active: bool = false
var _hunt_timer: float = 0.0
var _on_cooldown: bool = false


func _ready() -> void:
	set_process(false) # don't run until activated


func _process(delta: float) -> void:
	if not _active or _on_cooldown:
		return

	if _is_player_looking_at(hunt_location):
		_hunt_timer += delta
		if _hunt_timer >= attack_threshold:
			_perform_attack()
	else:
		_hunt_timer = 0.0


func _is_player_looking_at(target: int) -> bool:
	var main: Main = get_node_or_null("/root/Main")
	return main.looking_at == target


func _perform_attack() -> void:
	print("%s is attacking!" % stage_name)
	_on_cooldown = true
	set_process(false)

	_jumpscare()

	await get_tree().create_timer(cooldown_time).timeout
	_hunt_timer = 0.0
	_on_cooldown = false
	set_process(true)


func _jumpscare() -> void:
	# override per manifestation
	pass


func activate() -> void:
	if not _active:
		_active = true
		_hunt_timer = 0.0
		_on_cooldown = false
		set_process(true)
		print("manifestation.gd: %s manifestation activated." % stage_name)


func deactivate() -> void:
	if _active:
		_active = false
		set_process(false)
		print("manifestation.gd: %s manifestation deactivated." % stage_name)
