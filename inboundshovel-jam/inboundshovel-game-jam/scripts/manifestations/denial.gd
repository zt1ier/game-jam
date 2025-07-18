class_name Denial extends Manifestation


const STAGE_1_SPRITE = preload("res://assets/manifestations/denial-1.png")
const STAGE_2_SPRITE = preload("res://assets/manifestations/denial-2.png")


@onready var monitor: Monitor = $"../../Room/Furniture/Monitor"


var turned_on_visual: Node3D = null

var min_monitor_disable_chance: float = 0.05 # 5%
var max_monitor_disable_chance: float = 0.7 # 70%
var disable_check_interval: float = 2.0
var disable_timer: float = 0.0


func _ready() -> void:
	turned_on_visual = monitor.get_child(0) # assuming "TurnedOn" is the first child
	super()


func _tick_behavior(delta: float) -> void:
	if _is_player_looking_at(hunt_location): # player is looking at monitor, slow increase
		_hunt_meter = max(0, _hunt_meter - aggression_decay_rate * delta)
	else: # player is not looking at monitor
		if GameManager.is_monitor_on(): # but monitor is on, regular increase
			_hunt_meter += aggression_level * delta
		else: # and monitor is off, fast increase
			_hunt_meter += (aggression_level * 1.5) * delta

		# monitor sabotage attempt
		disable_timer += delta
		if disable_timer >= disable_check_interval:
			disable_timer = 0.0
			_attempt_monitor_disable()


func _stage_zero() -> void:
	# hide all FX/presence signs
	stage_visual.hide()


func _stage_one() -> void:
	stage_visual.show()

	stage_visual.texture = STAGE_1_SPRITE


func _stage_two() -> void:
	stage_visual.texture = STAGE_2_SPRITE


func _jumpscare() -> void:
	pass


func _attempt_monitor_disable() -> void:
	if monitor == null or not GameManager.is_monitor_on():
		return

	var aggression_ratio = clamp(_hunt_meter / hunt_stages[1], 0.0, 1.0)
	var chance = lerp(min_monitor_disable_chance, max_monitor_disable_chance, aggression_ratio)
	print("denial.gd: Monitor disable chance %d" % chance)

	if randf() < chance:
		monitor.toggle()
		print("Denial turned off the monitor because energy should be conserved")
