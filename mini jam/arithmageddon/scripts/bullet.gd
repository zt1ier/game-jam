class_name Bullet
extends CharacterBody2D


@export_subgroup("Parameters")
@export var speed: float = 300.0


var operation: Operation
var direction: Vector2


@onready var label: Label = $OperationLabel


func _ready() -> void:
	label.text = operation.icon


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_hitbox_body_entered(body: Enemy) -> void:
	print("Bullet hit ", body.number, ".")
	
	if operation:
		var effect = operation.effect.new()
		if effect.has_method("calculate"):
			effect.calculate(body, operation)
		else:
			print("No 'calculate' method found.")
	else:
		print("'Operation' does not exist.")
		
	queue_free()


func _on_screen_exited() -> void:
	queue_free()
