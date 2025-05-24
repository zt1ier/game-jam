extends Node


## sample last names in the fictional country Velkria
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

## sample last names in the fictional country Velkria
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

## sample cities in the fictional country Velkria
var cities: Array = [
	"Yelgrad",
	"Tarnova",
	"Drelvek",
	"Mazren",
	"Ulbera",
]

var doctor_names: Array = [
	"Melen Marquin",
	"Yarin Khech",
	"Sulen Vash",
	"Rovix Levij",
	"Talan Palan"
]

## doctor notes on citizen's medical condition
## if citizen has one of these conditions and noted by doctor,
## citizen can have free pass tier upgrade on relevant pass (asthma = oxygen pass)
var conditions: Dictionary = {
	"oxygen": ["Asthma", "Bronchitis"],
	"heat": ["Hypothermia", "Cold Sensitivity"],
	"water": ["Dehydration", "Kidney Problems"]
}

## letters used for generating code prefixes
var letters: Array = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
]


## randomize game's internal seed
func _ready() -> void:
	randomize()


## generate a random citizen dictionary with name, city, and birth year
func generate_citizen() -> Dictionary:
	## pick random variables from the lists above
	var first_name = first_names[randi() % first_names.size()]
	var last_name = last_names[randi() % last_names.size()]
	var full_name = first_name + " " + last_name
	var city = cities[randi() % cities.size()]
	var birth_year = _random_date(1930, 1960)
	var id_number = _generate_unique_id_number()

	## return generated citizen data as a dictionary
	return {
		"first_name": first_name,
		"last_name": last_name,
		"full_name": full_name,
		"city": city,
		"birth_year": birth_year,
		"id_number": id_number
	}


## same old same old
func generate_subscription_pass(prefix: String, id_number: String) -> Dictionary:
	## prefix is "OX", "HT", or "WR" depending on type
	var embossed_code := prefix + "-" + id_number
	var issue_date = _random_date(1978, 1979)
	var expiry_date = _expiry_date(issue_date)

	return {
		"embossed_code": embossed_code,
		"issue_date": issue_date,
		"expiry_date": expiry_date
	}


## you know the drill
func generate_medical_certificate(id_number: String) -> Dictionary:
	var issue_date = _random_date(1979, 1980)
	var valid_until = _expiry_date(issue_date) ## basically expiry date but cooler
	var doctor_name = "Dr. " + doctor_names[randi() % doctor_names.size()]
	var certificate_id = "MC" + "-" + id_number

	## pick random need (oxygen, heat, water) from conditions dictionary
	var needs = conditions.keys()
	var random_need = needs[randi() % needs.size()]

	var conditions_list = conditions[random_need]
	var medical_condition = conditions_list[randi() % conditions_list.size()]

	return {
		"issue_date": issue_date,
		"doctor_name": doctor_name,
		"medical_condition": medical_condition,
		"needs_category": random_need, ## this will be hidden, used only for discrepancy checks
		"certificate_id": certificate_id,
		"valid_until": valid_until
	}


func generate_payment_receipt() -> Dictionary:
	var payment_date = _random_date(1979, 1980)
	var payment_amounts = [10, 20, 30, 40, 50]
	var payment_amount = payment_amounts[randi() % payment_amounts.size()]
	var receipt_number = str(randi() % 10000000).pad_zeros(7)

	return {
		"payment_date": payment_date,
		"payment_amount": payment_amount,
		"receipt_number": receipt_number
	}


func generate_id_code(id_number: String) -> String:
	var id_letter = letters[randi() % letters.size()]
	return id_letter + "-" + id_number


func _generate_unique_id_number() -> String:
	return str(randi() % 10000000).pad_zeros(7)


## helper function to generate a random date string in YYYY-MM-DD (ISO) format
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
	return "%.4d-%.2d-%.2d" % [year, month, day]


func _expiry_date(issue_date: String) -> String:
	## parse year, month, and day from issue_date
	var year := int(issue_date.substr(0, 4))
	var month := int(issue_date.substr(5, 2))
	var day := int(issue_date.substr(8, 2))
	## substr(from, length) so from 5, move 2 digits forward

	var expiry_year := year + 1

	## fallback to 28 if February 29
	if month == 2 and day == 29 and not _is_leap_year(expiry_year):
		day = 28

	return "%.4d-%.2d-%.2d" % [expiry_year, month, day]


## helper function to determine if year is leap year
func _is_leap_year(year: int) -> bool:
	## leap year if divisible by 4 but not 100, unless divisible by 400
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
