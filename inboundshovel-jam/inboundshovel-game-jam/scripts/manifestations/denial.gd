class_name Denial extends Manifestation


@export var turned_on_path: NodePath = ^"../../Room/Furniture/Monitor/TurnedOnVisual"


var turned_on_visual: Node3D = null


func _ready() -> void:
	turned_on_visual = get_node_or_null(turned_on_path)
	super()


func _tick_behavior(delta: float) -> void:
	if _is_player_looking_at(hunt_location):
		# player is watching -> cool off, chill out, watch some Life Series
		_hunt_meter = max(0, _hunt_meter - aggression_decay_rate * delta)
	else:
		# player is NOT watching
		if GameManager.is_monitor_on():
			# monitor ON -> normal aggression
			_hunt_meter += aggression_level * delta
		else:
			# monitor OFF -> increased aggression
			_hunt_meter += (aggression_level * 1.5) * delta



func _stage_zero() -> void:
	# hide all FX/presence signs
	if visible == true:
		visible = false


func _stage_one() -> void:
	if turned_on_visual == null:
		print("denial.gd: 'turned_on' object is null.")
		return

	# turn off monitor screen
	if turned_on_visual.visible == true:
		turned_on_visual.visible = false


func _stage_two() -> void:
	# show manifestation
	if visible == false:
		visible = true


func _jumpscare() -> void:
	pass
