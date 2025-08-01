extends Node


# level, scene path
var levels: Dictionary[int, String] = {
	1: "res://levels/one/level_one.tscn",
}

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
