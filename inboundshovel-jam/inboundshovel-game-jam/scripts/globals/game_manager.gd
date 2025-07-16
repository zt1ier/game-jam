extends Node


const MAX_LEVEL: int = 5
const SHAKE_STRENGTH: int = 12


# level, layers
# external = what others say, usually misguided support
# internal = what the player thinks and tells themselves, unraveling thoughts (wrapped in BBCode)
var level_dialogue: Dictionary[int, Dictionary] = {
	1: { # denial
		"external": "They wouldn’t want you to dwell on it.",
		"internal": "[shake level=15]If I don’t think about it, maybe it didn’t really happen."
	},

	2: { # anger
		"external": "You’re being too sensitive. Try to calm down.",
		"internal": "[shake level=20]You say that like this isn’t tearing me apart."
	},

	3: { # bargaining
		"external": "Maybe if you set small goals, things will feel easier.",
		"internal": "[shake level=10]If I’d called sooner... it wouldn't be like this."
	},

	4: { # depression
		"external": "Sometimes we all just need to push through.",
		"internal": "[shake level=7]Why bother?"
	},

	5: { # acceptance
		"external": "See? You’re already doing better. You got it.",
		"internal": "[shake level=4]...I’m learning to carry it. That’s all."
	},
}

var current_level: int = 1

var manifestations: Node3D = null
var dialogue_scene: DialogueScene = null
var monitor: Monitor = null


func get_dialogue(layer: String) -> String:
	var layers = level_dialogue.get(current_level, {})
	var line = layers.get(layer, "")

	print(line)
	return line


func next_level() -> void:
	if dialogue_scene.is_animating:
		return

	if current_level < MAX_LEVEL:
		current_level += 1
		if dialogue_scene != null:
			dialogue_scene.update_label()


func is_monitor_on() -> bool:
	return monitor and monitor.is_on
