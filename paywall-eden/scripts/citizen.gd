class_name Citizen extends Node2D


## from 0 to 1, 0.5 is 50%
@export var discrepancy_chance: float = 0.35


var citizen_data: Dictionary = {}


func _ready() -> void:
	_generate_citizen()
	_handle_discrepancy()
	print(citizen_data)


func _generate_citizen() -> void:
	var citizen := CitizenGenerator.generate_citizen()
	var id_number = citizen["id_number"]

	if not id_number:
		print("no id_number key in citizen")
		return

	citizen_data = {
		"citizen": citizen,
		"id_card": CitizenGenerator.generate_id_code(id_number),
		"oxygen_pass": CitizenGenerator.generate_subscription_pass("OX", id_number),
		"heat_pass": CitizenGenerator.generate_subscription_pass("HT", id_number),
		"water_pass": CitizenGenerator.generate_subscription_pass("WR", id_number),
		"medical_certificate": CitizenGenerator.generate_medical_certificate(id_number),
		"payment_receipt": CitizenGenerator.generate_payment_receipt()
	}


func _handle_discrepancy() -> void:
	for key in citizen_data.keys():
		## skip the 'citizen' key because it is not a document
		if key == "citizen":
			continue

		var doc = citizen_data[key]

		if randf() <= discrepancy_chance:
			## if dictionary, continue to injection
			if typeof(doc) == TYPE_DICTIONARY:
				_inject_discrepancy(doc, key)
			elif typeof(doc) == TYPE_STRING:
				## wrap string in dictionary for consistency (like id_card or something)
				var fake_doc := {"id_code": doc}
				_inject_discrepancy(fake_doc, key)
				citizen_data[key] = fake_doc["id_code"] ## unwrap back to string


func _inject_discrepancy(doc: Dictionary, doc_name: String) -> void:
	## how many discrepancies to inject (0, 1, 2)
	var discrepancy_count = randi() % 2

	## fields to corrupt and inject discrepancies to
	var candidates = []
	
	if doc.has("embossed_code"):
		## then doc is subscription pass
		candidates = ["embossed_code", "issue_date", "expiry_date"]
	elif doc.has("certificate_id"):
		## then doc is medical certificate
		candidates = ["issue_date", "doctor_name", "certificate_id", "valid_until"]
	elif doc.has("receipt_number"):
		## then doc is payment receipt
		candidates = ["payment_date", "payment_amount", "receipt_number"]
	elif typeof(doc) == TYPE_STRING:
		## if doc is a string and not dictionary
		## fallback that might not be needed but it's here anyways
		print("doc is string and not dictionary blawg")
		return
	else:
		## default fallback, all keys in doc
		candidates = doc.keys()

	## clamp discrepancy count to candidates count in case
	discrepancy_count = min(discrepancy_count, candidates.size())

	var chosen_fields = []

	while chosen_fields.size() < discrepancy_count:
		var field = candidates[randi() % candidates.size()]
		if field not in chosen_fields:
			chosen_fields.append(field)
	
	for field in chosen_fields:
		_corrupt_field(doc, field, doc_name)


func _corrupt_field(doc: Dictionary, field: String, doc_name: String) -> void:
	if not doc.has(field):
		print("doc not have field: '%s' :(" % [field])
		return

	var old_val = doc[field]
	var new_val

	if typeof(old_val) == TYPE_STRING:
		if old_val.length() > 0:
			var index = randi() % old_val.length()
			var old_char_code = old_val.unicode_at(index)
			var new_char_code = old_char_code

			## ASCII stuff, randomize letters and numbers
			if is_letter_or_digit(old_char_code):
				while new_char_code == old_char_code:
					if old_char_code >= 65 and old_char_code <= 90:
						## uppercase letters A-Z
						new_char_code = randi_range(65, 90)
					elif old_char_code >= 97 and old_char_code <= 122:
						## lowercase letters a-z
						new_char_code = randi_range(97, 122)
					elif old_char_code >= 48 and old_char_code <= 57:
						## numbers 0-9
						new_char_code = randi_range(48, 57)

				var corrupted_char = char(new_char_code)
				new_val = old_val.substr(0, index) + corrupted_char + old_val.substr(index + 1)

			else:
				## if char is not letter or digit, keep original string
				new_val = old_val
		else:
			new_val = "???"
	else:
		new_val = "???"

	doc[field] = new_val

	## debug print
	print("corrupted doc: '%s' | field: '%s' | before: '%s' | after: '%s'" \
	% [doc_name, field, str(old_val), str(new_val)])


func is_letter_or_digit(code: int) -> bool:
	## 65-90 are uppercase letters, 97-122 are lowercase letters, 48-57 are numbers
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
