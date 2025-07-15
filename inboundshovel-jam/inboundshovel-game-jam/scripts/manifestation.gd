class_name Manifestation extends Node3D


signal attacked(manifestation: Manifestation) # emitted when the manifestation attacks


@export var stage_name: String = "" # grief stage name
@export var active_day: int = 1 # day it activates

@export_group("Hunt Parameters")
@export var hunt_stages: Array[float] = [1.0, 3.0, 5.0] # hunt meter thresholds
@export var hunt_location: int = 0 # player view index it hunts from (matches with Main.LookingAt)
@export var aggression_level: float = 1.0 # hunt meter increase rate
@export var aggression_decay_rate: float = 2.0 # hunt meter decrease rate
@export var cooldown_time: float = 3.0 # time after attacking before restarting


var _active := false
var _hunt_meter := 0.0
var _on_cooldown := false
var _last_stage_index := -1


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if not _active or _on_cooldown:
		return

	_tick_behavior(delta)
	_update_hunt_stage()

	if _hunt_meter >= hunt_stages.back():
		_perform_attack()


func _tick_behavior(delta: float) -> void:
	if _is_player_looking_at(hunt_location):
		_hunt_meter = max(0, _hunt_meter - aggression_decay_rate * delta)
	else:
		_hunt_meter += aggression_level * delta


func _update_hunt_stage() -> void:
	var new_stage := -1

	for i in hunt_stages.size():
		if _hunt_meter < hunt_stages[i]:
			new_stage = i - 1
			break

	if new_stage == -1:
		new_stage = hunt_stages.size() - 1

	if new_stage != _last_stage_index:
		_last_stage_index = new_stage
		_on_hunt_stage(new_stage)
		emit_signal("hunt_stage_changed", self, new_stage)


func _on_hunt_stage(stage_index: int) -> void:
	print("%s reached hunt stage %d" % [stage_name, stage_index])


func _perform_attack() -> void:
	if _on_cooldown:
		return

	_on_cooldown = true
	set_process(false)
	print("%s is attacking!" % stage_name)
	emit_signal("attacked", self)

	_jumpscare()

	await get_tree().create_timer(cooldown_time).timeout
	_hunt_meter = 0.0
	_last_stage_index = -1
	_on_hunt_stage(-1)
	_on_cooldown = false
	set_process(true)


func _jumpscare() -> void:
	pass


func _is_player_looking_at(target: int) -> bool:
	var main: Main = get_node_or_null("/root/Main")
	return main and main.looking_at == target


func activate() -> void:
	if _active:
		return

	var main: Main = get_node_or_null("/root/Main")
	if main and main.current_day < active_day:
		return

	_active = true
	_hunt_meter = 0.0
	_last_stage_index = -1
	_on_cooldown = false
	set_process(true)
	print("manifestation.gd: %s activated." % stage_name)


func deactivate() -> void:
	if not _active:
		return

	_active = false
	set_process(false)
	print("manifestation.gd: %s deactivated." % stage_name)
