extends Node


var generated_customers: int = 5


## data of customers before corruption injection
var customer_data: Dictionary = {}


func _ready() -> void:
	_generate()

	for customer in customer_data.keys():
		print("%s\n\n" % customer_data[customer])


func _generate() -> void:
	while customer_data.size() < generated_customers:
		var customer := CustomerGenerator.generate_customer()
		var account_id = customer.get("account_id", "")

		if not customer_data.has(account_id):
			customer_data[account_id] = customer


func get_customer_by_id(account_id: String) -> Dictionary:
	if customer_data.has(account_id):
		return customer_data[account_id]
	return {}
 

func is_letter_or_digit(code: int) -> bool:
	## 65-90 are uppercase letters, 97-122 are lowercase letters, 48-57 are numbers
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
