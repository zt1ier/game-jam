class_name Monitor extends Control


@onready var search_bar: LineEdit = $TabContainer/Accounts/Content/SearchSection/SearchBar
@onready var search_results: RichTextLabel = $TabContainer/Accounts/Content/ScrollContainer/SearchResults


func _ready() -> void:
	search_bar.connect("text_submitted", Callable(self, "_on_search_bar_text_submitted"))


func _on_search_bar_text_submitted(query: String) -> void:
	search_results.clear()

	var customer = CustomerData.get_customer_by_id(query)
	print(customer)

	if customer.is_empty():
		search_results.append_text("No account found with ID: %s" % query)
		return

	var summary := "Name: %s\n" % customer.full_name
	summary += "Address: %s\n" % customer.city
	summary += "Account Created: %s\n" % customer.account_created
	summary += "Subscriptions:\n"

	for service in customer.subscriptions.keys():
		var sub = customer.subscriptions[service]
		summary += " - %s: %s (Paid: %s, Due: %s)\n" % [
			service, sub.status, sub.last_payment, sub.next_due
		]

	search_results.append_text(summary)
