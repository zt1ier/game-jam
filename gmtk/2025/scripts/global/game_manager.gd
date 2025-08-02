extends Node


# level, scene path
var levels: Dictionary[int, String] = {
	1: "res://levels/one/level_one.tscn",
	2: "res://levels/two/level_two.tscn",
	3: "",
	4: "",
	5: "",
	6: "",
	7: "",
	8: "",   # end
}

var level_times: Dictionary[int, float] = {
	
}


var in_main_menu: bool = true
var intro_sequence: bool = false

var current_level: int = 1

var tree: SceneTree = null


func next_level() -> void:
	if tree == null:
		printerr("game_manager autoload: 'tree' property is null")
		return

	current_level += 1
	var level_scene = levels.get(current_level, levels.get(1))

	tree.change_scene_to_file(level_scene)
	print("game_manager autoload: changed scene to level %d" % current_level)


func format_time(t: float) -> String:
	var total_ms := int(t * 1000.0)
	var minutes := total_ms / 60000
	var seconds := (total_ms / 1000) % 60
	var milliseconds := total_ms % 1000

	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
