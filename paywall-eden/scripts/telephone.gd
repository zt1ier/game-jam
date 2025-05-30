class_name Telephone extends Control


@onready var call_button: Button = $CallButton
@onready var dialogue: Label = $DialogueLabel
@onready var responses: VBoxContainer = $Responses


func _ready() -> void:
	call_button.connect("pressed", Callable(self, "_on_call_answered"))


func _on_call_answered() -> void:
	print("call answered")
	call_button.hide()
	_load_customer()


func _load_customer() -> void:
	var ids := CustomerData.customer_data.keys()
	if ids.is_empty():
		push_error("no customers loaded")
		return

	var customer_id = ids.pick_random()
	var customer_data = CustomerData.get_customer_by_id(customer_id)

	var service = customer_data.get("subscription", "electricity")
	var mood_points = customer_data.get("mood_points", randi_range(3, 5))
	var mood_key = DialogueTree.get_mood(mood_points)

	DialogueTree.current_branch = "player_greeting"

	var line = DialogueTree.get_dialogue(mood_key, service, customer_id)
	print(line)
