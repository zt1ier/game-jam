## customer generator
extends Node


var first_names: Array = [
	"Ilen",
	"Marik",
	"Dresa",
	"Torun",
	"Velna",
	"Rokel",
	"Sira",
	"Jand",
	"Orren",
	"Teyla",
	"Kalven",
	"Mirsa",
	"Dalik",
	"Erniv",
	"Sovra",
	"Tyrel",
	"Alven",
	"Lorin",
	"Mirel",
	"Danek",
	"Selvi",
	"Obran",
	"Elsha",
	"Remek",
	"Jarla",
	"Narev",
	"Belka",
	"Tulen",
	"Volet",
	"Harnil",
	"Ceran",
	"Liska",
	"Ruden",
	"Altra",
	"Drayel",
	"Erven",
	"Silna",
	"Kadel",
	"Zorik",
	"Vemra",
	"Derel",
	"Nayen",
	"Fralin",
	"Orsha",
	"Halrik",
	"Velsha",
	"Janov",
	"Miren",
	"Sarn",
	"Tivra",
]

var last_names: Array = [
	"Karven",
	"Drovek",
	"Surnel",
	"Valtov",
	"Merzen",
	"Bradal",
	"Drevik",
	"Tarnel",
	"Korin",
	"Veska",
	"Varnov",
	"Elsvek",
	"Trellin",
	"Zarnel",
	"Murev",
	"Ferlan",
	"Tolesk",
	"Jorev",
	"Delnik",
	"Andral",
	"Verkan",
	"Lomrek",
	"Salnev",
	"Druska",
	"Nerol",
	"Harvek",
	"Selron",
	"Bromel",
	"Yurek",
	"Tarmen",
	"Fesran",
	"Odrel",
	"Jaskin",
	"Norvel",
	"Meltra",
	"Kurek",
	"Valtren",
	"Elvon",
	"Previk",
	"Sharnov",
	"Gradel",
	"Orvek",
	"Malven",
	"Lursen",
	"Tanrik",
	"Jarnov",
	"Eslin",
	"Corvel",
	"Zaltek",
	"Vellin",
]

var cities: Array = [
	"Yelgrad",
	"Tarnova",
	"Drelvek",
	"Mazren",
	"Ulbera",
]

var sectors: Array = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
]

var services: Array = ["Electricity", "Water", "Heat"]
var statuses: Array = ["Active", "Suspended"]


static var _initialized: bool = false


var current_date: String = "1980-04-24"


## randomize game's internal seed
func _ready() -> void:
	if not _initialized:
		randomize()
		_initialized = true


## generate customer data
func generate_customer() -> Dictionary:
	var first_name = first_names.pick_random()
	var last_name = last_names.pick_random()
	var full_name = first_name + " " + last_name
	var mood_points = randi_range(3, 5)

	var sector = sectors.pick_random()
	var birth_year = randi_range(1930, 1960)
	var account_created_date = _random_date(1970, 1979)

	var subscriptions = {}
	for service in services:
		var last_payment = _date_before(current_date, 1, 2)
		var next_due = _date_after(last_payment, 1, 1)

		var previous_status = subscriptions.get(service, {}).get("status", null)
		var new_status = statuses.pick_random()

		if previous_status == "Suspended":
			while new_status == "Suspended":
				new_status = statuses.pick_random()

		subscriptions[service] = {
			"last_payment": last_payment,
			"next_due": next_due,
			"status": new_status
		}

	return {
		"full_name": full_name,
		"mood_points": mood_points,
		"birth_year": birth_year,
		"sector": sector,
		"account_created": account_created_date,
		"subscriptions": subscriptions
	}


func _random_date(min_year: int, max_year: int) -> String:
	## generate random year and month within given range
	var year := randi() % (max_year - min_year + 1) + min_year
	var month := randi() % 12 + 1

	## list of days per month in a non-leap year
	var days_in_month := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	## adjust February for leap years
	if month == 2 and _is_leap_year(year):
		days_in_month[1] = 29

	## generate random valid day for month
	var day = randi() % days_in_month[month - 1] + 1

	## format and return date as YYYY-MM-DD
	return "%04d-%02d-%02d" % [year, month, day]


func _date_before(date_reference: String, min_months: int, max_months: int) -> String:
	## doing something to the date reference, i forgot what the word is
	var parts = date_reference.split("-")
	var ref_year = int(parts[0])
	var ref_month = int(parts[1])

	## choose random number of months to subtract
	var months_ago = randi_range(min_months, max_months)
	var new_month = ref_month - months_ago
	var new_year = ref_year

	## if january or less, go back one year before
	while new_month < 1:
		new_month += 12
		new_year -= 1

	var days_in_month := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if new_month == 2 and _is_leap_year(new_year):
		days_in_month[1] = 29

	var new_day = randi_range(1, days_in_month[new_month - 1])

	## format and return date as YYYY-MM-DD
	return "%04d-%02d-%02d" % [new_year, new_month, new_day]


## inherently the same with _date_before() but addition
func _date_after(date_reference: String, min_months: int, max_months) -> String:
	var parts = date_reference.split("-")
	var year = int(parts[0])
	var month = int(parts[1])
	var day = int(parts[2])

	var add_months = randi_range(min_months, max_months)
	month += add_months

	while month > 12:
		month -= 12
		year += 1

	var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and _is_leap_year(year):
		days_in_month[1] = 29

	day = min(day, days_in_month[month - 1])

	return "%04d-%02d-%02d" % [year, month, day]


func _is_leap_year(year: int) -> bool:
	## leap year if divisible by 4 but not 100, unless divisible by 400 --- google
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
