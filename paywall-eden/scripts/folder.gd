class_name Folder extends Control


var customer_data: Dictionary = {}


## from 0 to 1, 0.5 is 50%
@export var discrepancy_chance: float = 0.35


var citizen_data: Dictionary = {}


func _ready() -> void:
	_generate_citizen()
	print("BEFORE\n-------------------------\n%s\n" % citizen_data)
	_handle_discrepancy()
	print("\nAFTER\n-------------------------\n%s" % citizen_data)

	_folder_integration()


func _generate_citizen() -> void:
	var citizen_id = CustomerGenerator.generate_citizen()
	var id_number = citizen_id["id_number"]

	if not id_number:
		print("no id_number key in citizen")
		return

	citizen_data = {
		"citizen_id": citizen_id,
		"oxygen_pass": CustomerGenerator.generate_subscription_pass("OX", id_number),
		"heat_pass": CustomerGenerator.generate_subscription_pass("HT", id_number),
		"water_pass": CustomerGenerator.generate_subscription_pass("WR", id_number),
		"medical_certificate": CustomerGenerator.generate_medical_certificate(id_number),
		"payment_receipt": CustomerGenerator.generate_payment_receipt()
	}

	if randf() <= medical_chance:
		citizen_data.erase("medical_certificate")


func _handle_discrepancy() -> void:
	for key in citizen_data.keys():
		var doc = citizen_data[key]

		if typeof(doc) != TYPE_DICTIONARY:
			return
		else:
			if randf() <= discrepancy_chance:
				_inject_discrepancy(doc, key)


func _folder_integration() -> void:
	for key in citizen_data.keys():
		if key == "id_code":
			continue

		var doc_data = citizen_data[key]

		var tab := MarginContainer.new()
		tab.add_theme_constant_override("margin_left", folder_margin)
		tab.add_theme_constant_override("margin_right", folder_margin)
		tab.add_theme_constant_override("margin_bottom", folder_margin)
		tab.add_theme_constant_override("margin_top", folder_margin)
		tab.name = _prettify_key(key)

		var content = RichTextLabel.new()
		content.text = _format_document(doc_data)
		content.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		content.custom_minimum_size = document_size
		tab.add_child(content)
		tabs.add_child(tab)


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
			var tries := 0
			var index = randi() % old_val.length()
			var old_char_code = old_val.unicode_at(index)

			while not is_letter_or_digit(old_char_code) and tries < old_val.length():
				index = (index + 1) % old_val.length()
				old_char_code = old_val.unicode_at(index)
				tries += 1

			## ASCII stuff, randomize letters and numbers
			if is_letter_or_digit(old_char_code):
				var new_char_code = old_char_code
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


func _format_document(doc_data: Dictionary) -> String:
	if typeof(doc_data) == TYPE_DICTIONARY:
		var lines := []

		for key in doc_data.keys():
			if key == "needs_category" or key == "first_name" \
			or key == "last_name" or key == "id_number":
				continue
			var label = _prettify_key(key)
			lines.append("%s: %s" % [label, str(doc_data[key])])

		return "\n".join(lines)

	elif typeof(doc_data) == TYPE_STRING:
		return "ID Code\n%s" % doc_data

	else:
		return "Unsupported data type: %s" % typeof(doc_data)


func _prettify_key(key: String) -> String:
	match key:
		"full_name": return "Name"
		"city": return "Address"
		"birth_year": return "Birthdate"
		"id_number": return "ID Number"
		"id_code": return "ID Code"
		"embossed_code": return "Embossed Code"
		"issue_date": return "Issue Date"
		"expiry_date": return "Expiry Date"
		"doctor_name": return "Name of Doctor"
		"medical_condition": return "Medical Condition"
		"certificate_id": return "Certificate ID"
		"valid_until": return "Valid Until"
		"payment_date": return "Paid On"
		"payment_amount": return "Payment Amount"
		"receipt_number": return "Receipt Number"
		"citizen_id": return "Citizen ID"
		"oxygen_pass": return "Oxygen Pass"
		"water_pass": return "Water Pass"
		"heat_pass": return "Heat Pass"
		"medical_certificate": return "Medical Certificate"
		"payment_receipt": return "Payment Receipt"
		_:
			# fallback: "some_key_name" -> "Some Key Name"
			return key.capitalize().replace("_", " ")
