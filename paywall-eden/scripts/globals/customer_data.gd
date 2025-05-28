extends Node


var generated_customers: int = 1000


var customer_data: Dictionary = {}


func _ready() -> void:
	_generate()

	## debug
	for customer in customer_data.keys():
		print("ID: %s --- %s\n\n" % [customer, customer_data[customer]])


func _generate() -> void:
	var available_ids := []
	for id in range(1234567, 10000000):
		available_ids.append(id)

	available_ids.shuffle()

	for i in range(generated_customers):
		var customer := CustomerGenerator.generate_customer()
		var account_id = str(available_ids[i])
		customer["account_id"] = account_id
		customer_data[account_id] = customer


func get_customer_by_id(account_id: String) -> Dictionary:
	if customer_data.has(account_id):
		return customer_data[account_id]
	return {}
 

func is_letter_or_digit(code: int) -> bool:
	## 65-90 are uppercase letters, 97-122 are lowercase letters, 48-57 are numbers
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
