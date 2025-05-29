extends Node


var generated_customers: int = 15000


var customer_data: Dictionary = {}

var thread = Thread.new()


func _ready() -> void:
	var thread_data := { "count" : generated_customers}
	var callable := Callable(self, "_generate").bind(thread_data)
	thread.start(callable)


func _generate(data: Dictionary) -> Dictionary:
	var generated_customers = data["count"]
	var local_customer_data := {}

	var available_ids := []
	for id in range(1, generated_customers + 1):
		available_ids.append(id)
	available_ids.shuffle()

	for i in range(generated_customers):
		var customer := CustomerGenerator.generate_customer()
		var account_id = str(available_ids[i]).pad_zeros(5)
		customer["account_id"] = account_id
		local_customer_data[account_id] = customer
		#print(i)

	return local_customer_data


func _process(delta: float) -> void:
	if not thread.is_alive() and customer_data.is_empty():
		var result = thread.wait_to_finish()
		customer_data = result

		## debug
		for customer in customer_data.keys():
			print("ID: %s --- %s\n\n" % [customer, customer_data[customer]])


func get_customer_by_id(account_id: String) -> Dictionary:
	if customer_data.has(account_id):
		return customer_data[account_id]
	return {}
 

func is_letter_or_digit(code: int) -> bool:
	## 65-90 are uppercase letters, 97-122 are lowercase letters, 48-57 are numbers
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
