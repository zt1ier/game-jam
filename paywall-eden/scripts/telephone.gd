class_name Telephone extends Control


@onready var call_button: Button = $CallButton
@onready var dialogue: Label = $DialogueLabel
@onready var responses: VBoxContainer = $Responses


var mood: int
var subscription: String
var id: String


func _ready() -> void:
	call_button.connect("pressed", Callable(self, "_on_call_answered"))


func _on_call_answered() -> void:
	#call_button.hide()
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

	mood = mood_points
	subscription = service
	id = customer_id

	_handle_dialogue(subscription, id)


func _handle_dialogue(service: String, customer_id: String) -> void:
	var mood_key = DialogueTree.get_mood(mood)

	var line = DialogueTree.get_dialogue(mood_key, service, customer_id)
	#print("chosen line: ", line)
	
	if typeof(line) == TYPE_DICTIONARY:
		_show_dialogue(line)
	elif typeof(line) == TYPE_STRING:
		_show_customer_dialogue(line)


func _show_dialogue(lines: Dictionary) -> void:
	for line in lines.values():
		print("line: ", line)
		if typeof(line) == TYPE_ARRAY:
			_show_player_responses(line)
		elif typeof(line) == TYPE_STRING:
			_show_customer_dialogue(line)
		else:
			printerr("uhhh something's not working")


func _show_customer_dialogue(line: String) -> void:
	dialogue.text = line


func _show_player_responses(lines: Array) -> void:
	for line in lines:
		var button = Button.new()
		button.text = line["text"]
		var callable := Callable(self, "_on_player_response_pressed")
		if line.has("value"):
			callable.bind(line["value"])
		button.connect("pressed", callable)
		responses.add_child(button)


func _on_player_response_pressed(mood_points: int = 0) -> void:
	mood += mood_points
	print("mood points: ", mood)

	## remove all existing button responses
	for child in responses.get_children():
		child.queue_free()

	_handle_dialogue(subscription, id)
