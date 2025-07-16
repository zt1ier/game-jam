class_name Manifestation extends Node3D


@export var stage_name: String = "" # grief stage name
@export var active_level: int = 1 # level it activates

@export_group("Hunt Parameters")
@export var hunt_stages: Array[float] = [5.0, 8.0, 10.0] # aggression thresholds, last triggers attack
@export var hunt_location: int = 0 # player view index it hunts from (matches with Main.LookingAt)
@export var aggression_level: float = 1.0 # hunt meter increase rate
@export var aggression_decay_rate: float = 2.0 # hunt meter decrease rate
@export var cooldown_time: float = 3.0 # time after attacking before restarting


# internal variables
var _active: bool = false
var _hunt_meter: float = 0.0
var _on_cooldown: bool = false
var _last_stage_index: int = 0
var _current_stage: int = 0


func _ready() -> void:
	add_to_group("Manifestation")
	set_process(false)

	activate()


func _process(delta: float) -> void:
	if not _active or _on_cooldown:
		return

	_tick_behavior(delta)
	_evaluate_stage()


func _tick_behavior(delta: float) -> void:
	# handle hunt meter increase/decrease based on monitor state and view
	if GameManager.is_monitor_on():
		# monitor ON = base aggression (slower)
		_hunt_meter += (aggression_level * 0.5) * delta
	else:
		if _is_player_looking_at(hunt_location):
			# being watched, decay faster
			_hunt_meter = max(0, _hunt_meter - aggression_decay_rate * delta)
		else:
			# not watched, increase at full rate
			_hunt_meter += aggression_level * delta


func _evaluate_stage() -> void:
	var new_stage := 0

	if _hunt_meter < hunt_stages[0]:
		new_stage = 0
	elif _hunt_meter < hunt_stages[1]:
		new_stage = 1
	elif _hunt_meter < hunt_stages[2]:
		new_stage = 2
	else:
		new_stage = 3  # attack threshold

	if new_stage != _last_stage_index:
		_last_stage_index = new_stage
		_current_stage = new_stage
		_on_hunt_stage(new_stage)

	if new_stage == 3 and not _on_cooldown:
		_perform_attack()


func _on_hunt_stage(stage_index: int) -> void:
	# override in subclasses to play stage-specific effects
	match stage_index:
		0:
			_stage_zero() # reset all fx/hints
		1:
			_stage_one() # minimal presence
		2:
			_stage_two() # stronger signs
		3:
			pass # _perform_attack() is handled separately n _evaluate_stage()
		

	print("%s reached hunt stage %d" % [stage_name, stage_index])


func _stage_zero() -> void:
	pass


func _stage_one() -> void:
	pass


func _stage_two() -> void:
	pass


func _perform_attack() -> void:
	if _on_cooldown:
		return

	_on_cooldown = true
	set_process(false)
	print("%s is attacking!" % stage_name)

	_jumpscare()

	# reset after cooldown
	await get_tree().create_timer(cooldown_time).timeout
	_hunt_meter = 0.0
	_last_stage_index = 0
	_on_hunt_stage(0)
	_on_cooldown = false
	set_process(true)


func _jumpscare() -> void:
	# override per subclass
	pass


func _is_player_looking_at(target: int) -> bool:
	# queries Main node for current player view
	var main: Main = get_node_or_null("/root/Main")
	return main and main.looking_at == target


func activate() -> void:
	if _active:
		return

	# only activate if current_level matches active_level
	if GameManager.current_level < active_level:
		print("manifestation.gd: 'current_level' is less than 'active_level'")
		return

	hide()
	_active = true
	_hunt_meter = 0.0
	_last_stage_index = 0
	_on_cooldown = false
	set_process(true)
	print("manifestation.gd: %s activated" % stage_name)


func deactivate() -> void:
	if not _active:
		return

	_active = false
	set_process(false)
	print("manifestation.gd: %s deactivated" % stage_name)
