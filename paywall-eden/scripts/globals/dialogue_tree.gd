extends Node


var dialogue_tree: Dictionary = {



	"player_greeting": {
		"-1": [
			{"text": "What’s the issue?", "next": "customer_greeting"},
			{"text": "Hurry it up. What's the problem?", "next": "customer_greeting"},
			{"text": "Get to the point. I'm busy.", "next": "customer_greeting"}
		],
		"0": [
			{"text": "Hello, how can I assist you today?", "next": "customer_greeting"},
			{"text": "Hi, tell me what’s going on.", "next": "customer_greeting"},
			{"text": "Go ahead. What seems to be the problem?", "next": "customer_greeting"}
		],
		"+1": [
			{"text": "Hi there! Let’s get you sorted.", "next": "customer_greeting"},
			{"text": "Great to hear from you! What can I do for you today?", "next": "customer_greeting"},
			{"text": "Thanks for calling! Let's fix this together.", "next": "customer_greeting"}
		]
	},



	"customer_greeting": {
		"angry": [
			{"text": "Took you long enough. Fix it already.", "next": "customer_issue_report"},
			{"text": "Whatever. Let’s just get this over with.", "next": "customer_issue_report"},
			{"text": "Do your job for once!", "next": "customer_issue_report"}
		],
		"neutral": [
			{"text": "Hi. I hope you can help.", "next": "customer_issue_report"},
			{"text": "Hello, I’ve got an issue again.", "next": "customer_issue_report"},
			{"text": "Hey. Something’s not working.", "next": "customer_issue_report"}
		],
	},



	"customer_issue_report": {
		"electricity": {
			"angry": [
				{"text": "No power again. What am I even paying for?", "next": "player_issue_report"},
				{"text": "Another blackout! Fix it!", "next": "player_issue_report"},
				{"text": "The power's out! Come on!", "next": "player_issue_report"}
			],
			"neutral": [
				{"text": "My electricity’s out again. Can you help?", "next": "player_issue_report"},
				{"text": "My lights are out.", "next": "player_issue_report"},
				{"text": "The lights are gone. Any idea why?", "next": "player_issue_report"}
			],
		},
		"water": {
			"angry": [
				{"text": "Still no water! What’s your excuse this time?", "next": "player_issue_report"},
				{"text": "Every week it’s the same! I want answers.", "next": "player_issue_report"},
				{"text": "Water's out? Again? Unreal!", "next": "player_issue_report"}
			],
			"neutral": [
				{"text": "No water here. Is it a known issue?", "next": "player_issue_report"},
				{"text": "Water's not coming through.", "next": "player_issue_report"},
				{"text": "I noticed the taps stopped. Anything going on?", "next": "player_issue_report"}
			],
		},
		"heat": {
			"angry": [
				{"text": "Freezing in here! What am I paying for?", "next": "player_issue_report"},
				{"text": "Heat cut again. Great job.", "next": "player_issue_report"},
				{"text": "This is pathetic. Still no heat.", "next": "player_issue_report"}
			],
			"neutral": [
				{"text": "Is the heating down for everyone?", "next": "player_issue_report"},
				{"text": "Can you check the heating? Mine's gone.", "next": "player_issue_report"},
				{"text": "Just reporting — my heating stopped.", "next": "player_issue_report"}
			],
		}
	},



	"player_issue_report": {
		"-1": [
			{"text": "Sounds like your fault. ID?", "next": "customer_get_account"},
			{"text": "Give me your ID.", "next": "customer_get_account"},
			{"text": "Bet you didn’t pay. ID?", "next": "customer_get_account"}
		],
		"0": [
			{"text": "Could be a glitch. I’ll need your ID.", "next": "customer_get_account"},
			{"text": "Let’s check your account. Can you give me your ID?", "next": "customer_get_account"},
			{"text": "Alright. First, your account ID please.", "next": "customer_get_account"}
		],
		"+1": [
			{"text": "Let's get this fixed. What’s your ID?", "next": "customer_get_account"},
			{"text": "I’ll take care of it — just need your ID.", "next": "customer_get_account"},
			{"text": "No worries, we’ll sort this out. ID please!", "next": "customer_get_account"}
		]
	},



	"customer_get_account": {
		"angry": [
			{"text": "Just fix it already. {account_id}", "next": "system_check"},
			{"text": "Take the damn ID: {account_id}", "next": "system_check"},
			{"text": "Whatever. It’s {account_id}.", "next": "system_check"}
		],
		"neutral": [
			{"text": "It’s {account_id}.", "next": "system_check"},
			{"text": "My ID is {account_id}", "next": "system_check"},
			{"text": "{account_id}.", "next": "system_check"}
		],
		"grateful": [
			{"text": "Thank you. My ID is {account_id}.", "next": "system_check"},
			{"text": "Really appreciate it — here’s my ID: {account_id}", "next": "system_check"},
			{"text": "Cheers. It’s {account_id}.", "next": "system_check"}
		]
	},



	"system_check": {
		## no dialogue — player interacts with account data and system logs here
	},

	"notify_results": {
		## dynamic dialogue generated based on conditions
		## example:
		## if logs say "no payment", player says:
		## {"text": "Looks like your last bill wasn’t paid.", "next": "customer_reaction"}
		## if logs show service was cut:
		## {"text": "Service was disabled externally. Not our end.", "next": "customer_reaction"}
	},



	"customer_reaction": {
		"angry": [
			{"text": "That’s your excuse? Pathetic.", "next": "customer_negotiate"},
			{"text": "You call that support?", "next": "customer_negotiate"},
			{"text": "Unbelievable. Every time!", "next": "customer_negotiate"}
		],
		"neutral": [
			{"text": "Okay...", "next": "customer_negotiate"},
			{"text": "Alright...", "next": "customer_negotiate"},
			{"text": "I guess...", "next": "customer_negotiate"}
		],
		"grateful": [
			{"text": "Thanks for checking.", "next": "customer_negotiate"},
			{"text": "I appreciate you looking into it.", "next": "customer_negotiate"},
			{"text": "That helps. Thanks.", "next": "customer_negotiate"}
		]
	},



	"customer_negotiate": {
		"angry": [
			{"text": "You better fix this or I’m reporting you!", "next": "player_decision"},
			{"text": "I swear, if this isn’t solved now...", "next": "player_decision"},
			{"text": "Put someone competent on the line.", "next": "player_decision"}
		],
		"neutral": [
			{"text": "Is there any way you could restore it?", "next": "player_decision"},
			{"text": "Can this be fixed today?", "next": "player_decision"},
			{"text": "Can you do anything from your end?", "next": "player_decision"}
		],
		"grateful": [
			{"text": "Thanks again. If it helps, I’d really appreciate a reset.", "next": "player_decision"},
			{"text": "Is there any chance you could turn it back on?", "next": "player_decision"},
			{"text": "Could you please restore the service?", "next": "player_decision"}
		]
	},



	"player_decision": {
		"on": [
			{"text": "Manually overriding. Service restored.", "next": "call_end"},
			{"text": "Done. Your service is back online.", "next": "call_end"},
			{"text": "Restoring now. Don’t say I never helped.", "next": "call_end"}
		],
		"off": [
			{"text": "Can’t do anything. It stays off.", "next": "call_end"},
			{"text": "Sorry. Policy is clear. No service.", "next": "call_end"},
			{"text": "That’s a no from me. We’re done here.", "next": "call_end"}
		],
		"escalate": [
			{"text": "Forwarding your case to my supervisor.", "next": "call_end"},
			{"text": "I’ll escalate this. Someone will reach out.", "next": "call_end"},
			{"text": "Pushing this up the chain. Hang tight.", "next": "call_end"}
		]
	},



	"call_end": {
		## call ends
	}



}


var starting_branch: String = "player_greeting"
var current_branch: String


func _ready() -> void:
	current_branch = starting_branch


func get_dialogue(mood: String = "", subscription: String = "", account_id: String = "") -> Variant:
	var branch_data = dialogue_tree.get(current_branch, null)
	if branch_data == null:
		return "error: invalid dialogue branch"

	if typeof(branch_data) == TYPE_DICTIONARY:
		## then branch_data is player branch and contains responses
		if branch_data.has("-1") and branch_data.has("0") and branch_data.has("+1"):
			return {
				"dialogue_type": "player_choice",
				"options": branch_data,
			}

	## categorize by subscription and mood (issue_report)
	if subscription != "" and branch_data.has("subscription"):
		## then branch_data is customer branch
		var lines_by_mood = branch_data[subscription].get(mood, null)
		print(lines_by_mood)
		if lines_by_mood:
			var chosen_line = _pick_line(lines_by_mood, account_id)
			_set_next_branch(lines_by_mood, chosen_line)
			return {
				"dialogue_type": "customer_text",
				"text": chosen_line,
			}

	## categorize by mood only (not issue_report)
	if mood != "" and branch_data.has(mood):
		var lines_by_mood = branch_data[mood]
		var chosen_line = _pick_line(lines_by_mood, account_id)
		_set_next_branch(lines_by_mood, chosen_line)
		return {
			"dialogue_type": "customer_text",
			"text": chosen_line,
			}

	## if branch_data is a flat list, not a dictionary
	if typeof(branch_data) == TYPE_ARRAY:
		var chosen_line = _pick_line(branch_data, account_id)
		_set_next_branch(branch_data, chosen_line)
		return {
			"dialogue_type": "customer_text",
			"text": chosen_line,
		}

	return "error: unexpected dialogue format"


func get_mood(mood: int) -> String:
	if mood <= 3:
		return "angry"
	elif mood <= 6:
		return "neutral"
	else:
		return "grateful"


func _pick_line(lines: Array, account_id: String) -> String:
	var chosen_line = lines.pick_random()

	if chosen_line.has("text"):
		return chosen_line["text"].replace("{account_id}", account_id)
	elif typeof(chosen_line) == TYPE_STRING:
		return chosen_line.replace("{account_id}", account_id)

	return "error: no valid dialogue line found"


func _set_next_branch(lines: Array, chosen_lines: String) -> void:
	for line in lines:
		if line.has("text"):
			if line["text"].replace("{account_id}", "") == chosen_lines.replace("{account_id}", ""):
				current_branch = line.get("next", current_branch)
				return
