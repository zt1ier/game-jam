extends StaticBody2D


const BUILDING_SCENE = preload("res://scenes/building.tscn")
const ROCK_SCENE = preload("res://scenes/rock.tscn")
const TREE_SCENE = preload("res://scenes/tree.tscn")

var spawnable_objects: Array = [
	BUILDING_SCENE, 
	ROCK_SCENE, 
	TREE_SCENE
]


@export var offset_distance: float = 100.0


func _on_hurtbox_body_entered(bullet: Bullet) -> void:
	print(bullet.name, " entered ", name, ".")
	if bullet.operation.icon == "+":
		spawn_nearby()
	elif bullet.operation.icon == "-":
		queue_free()
	bullet.queue_free()


func spawn_nearby() -> void:
	print("Duplicated1: ", name, ".")
	var object_scene = spawnable_objects[randi() % spawnable_objects.size()]
	var new_object = object_scene.instantiate()
	
	var offset = Vector2(
		randf_range(-offset_distance, offset_distance),
		randf_range(-offset_distance, offset_distance)
	)
	
	new_object.global_position = global_position + offset
	new_object.scale = Vector2(randf_range(1, 2), randf_range(1, 2))
	
	get_parent().add_child(new_object)
	print("Duplicated2: ", name, ".")
