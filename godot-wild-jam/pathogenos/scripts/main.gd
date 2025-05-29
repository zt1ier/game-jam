extends Node2D

@onready var heat_bar: ProgressBar = $InfectCount/ProgressBar
@onready var player: CharacterBody2D = $Player
@onready var bg_particles: CPUParticles2D = $BackgroundParticles
@onready var rbc_scene: PackedScene = preload("res://scenes/red_blood_cell.tscn")
@onready var wbc_scene: PackedScene = preload("res://scenes/white_blood_cell.tscn")
@onready var infect_label: Label = $InfectCount/Label
@onready var coords_label: Label = $InfectCount/Label2
@onready var brain: Node2D = $Brain
@onready var infect_layer: CanvasLayer = $InfectCount
@onready var bgm: AudioStreamPlayer = $BackgroundMusic
@onready var hp1: TextureRect = $HealthIcons/HealthTexture
@onready var hp2: TextureRect = $HealthIcons/HealthTexture2
@onready var hp3: TextureRect = $HealthIcons/HealthTexture3
@onready var hp4: TextureRect = $HealthIcons/HealthTexture4
@onready var hp_icons: CanvasLayer = $HealthIcons
@onready var fever_bg: ColorRect = $FeverModeTint/ColorBackground
@onready var wbc_spawn_timer: Timer = $Brain/SpawnTimer

var fever_mode: bool = false
var fever_mode_activated: bool = false

var default_wbc_spawn_timer_value

var sprint_heat_gain: float
var max_heat: float = 50.0
var heat: float = 0.0

var worldev: WorldEnvironment
var saved_worldev: Environment

var last_player_pos: Vector2
var infect_count: int

var total_infected: int

var from_pause: bool = false

var game_running: bool = false
var game_victory: bool = false
var game_won: bool = false

# ^^^ i like booleans

var time: float = 0.0
var final_time: float

var paused: bool = false

var player_dead: bool = false

func _ready() -> void:
	default_wbc_spawn_timer_value = wbc_spawn_timer.wait_time
	
	worldev = $WorldEnvironment
	saved_worldev = worldev.environment
	
	game_running = false
	infect_layer.hide()
	$Menu.show()
	
	bg_particles.explosiveness = 0.9
	bg_particles.speed_scale = 1.0
	await get_tree().create_timer(0.22).timeout
	bg_particles.explosiveness = 0
	bg_particles.speed_scale = 0.02
	
	bgm.autoplay = true
	
	heat_bar.max_value = max_heat
	heat_bar.min_value = 0
	heat_bar.step = 1 * get_process_delta_time()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and game_running and not (game_victory or game_won):
		paused = true
		player.set_physics_process(false)
		$PauseMenu.show()
		Engine.time_scale = 0
	
	if game_running:
		if heat >= max_heat:
			fever_bg.modulate.a = 7.5
			$InfectCount/Label5.text = "The body is fighting back!\nFaster White speed and spawn rate."
			$InfectCount/Label5.show()
			_enter_fever_mode()
		elif heat >= (max_heat * 0.8):
			fever_bg.modulate.a = 6.0
		elif heat >= (max_heat * 0.6):
			fever_bg.modulate.a = 4.5
			if fever_mode:
				$InfectCount/Label5.text = "The body has cooled down..."
				_exit_fever_mode()
				await get_tree().create_timer(4).timeout
				$InfectCount/Label5.hide()
		elif heat >= (max_heat * 0.4):
			fever_bg.modulate.a = 3.0
		elif heat >= (max_heat * 0.2):
			fever_bg.modulate.a = 1.5
	
	heat_bar.value = heat
	
	match player.health:
		15:
			hp4.hide()
		10:
			hp3.hide()
		5:
			hp2.hide()
		0:
			hp1.hide()
			player_dead = true
	
	if bgm.playing == false:
		bgm.play()
	
	if brain.health == 0 and not game_won:
		time += 0.0
		final_time = time
		_victory()
		hp_icons.hide()
		game_won = true
		return
	
	if not game_running or game_victory:
		hp_icons.hide()
		player.hide()
		player.set_physics_process(false)
	elif not player_dead:
		hp_icons.show()
		if Engine.time_scale == 1:
			time += 0.01
		player.show()
		player.set_physics_process(true)
	
	infect_count = player.infect_count
	
	if Input.is_action_just_pressed("spawn_red"):
		var rbc = rbc_scene.instantiate()
		rbc.global_position = Vector2(2249, 1255)
		$RBCs.add_child(rbc)
	
	if Input.is_action_just_pressed("spawn_white"):
		var wbc = wbc_scene.instantiate()
		wbc.global_position = Vector2(2249, 1255)
		$WBCs.add_child(wbc)
	
	var rbc_count = get_tree().get_nodes_in_group("rbc").size()
	var wbc_count = get_tree().get_nodes_in_group("wbc").size()
	
	infect_label.text = "Infected" + str(player.infect_count)
	$InfectCount/TimeLabel.text = "RecordTime%.2f" % [time]
	
	$InfectCount/Label3.text = "Red" + str(rbc_count) + "\n" \
		+ "White" + str(wbc_count)

func _on_attack_boss_pressed() -> void:
	for infected in get_tree().get_nodes_in_group("infected"):
		if infected.has_method("_boss_battle"):
			infected._boss_battle()
			infected.boss_battling = true

func _on_play_game_button_pressed() -> void:
	game_running = true
	$Menu.hide()
	infect_layer.show()
	hp1.show()
	hp2.show()
	hp3.show()
	hp4.show()

func _victory():
	infect_layer.hide()
	$VictoryMenu.show()
	game_victory = true
	$VictoryMenu/Label.text = "You took over your host!\n\nTotal Infected%d\nFinal Time%.2f" \
		% [total_infected, final_time]

func _on_main_menu_pressed() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	$PauseMenu.hide()

func _on_info_button_pressed() -> void:
	$Menu.hide()
	$InfoMenu.show()

func _on_back_button_pressed() -> void:
	$InfoMenu.hide()
	if from_pause:
		$PauseMenu.show()
	else:
		$Menu.show()
		from_pause = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	Engine.time_scale = 1
	paused = false
	player.set_physics_process(true)
	$PauseMenu.hide()

func _on_glow_toggled(toggled_on: bool) -> void:
	toggled_on = not toggled_on
	if toggled_on:
		worldev.environment = null
		$InfoMenu/Optimize1.text = "Glow disabled"
	else:
		worldev.environment = saved_worldev
		$InfoMenu/Optimize1.text = "Glow enabled"

func _on_particles_toggled(toggled_on: bool) -> void:
	toggled_on = not toggled_on
	if toggled_on:
		$BackgroundParticles.emitting = true
		$BackgroundParticles.show()
		$InfoMenu/Optimize2.text = "Particles enabled"
	else:
		$BackgroundParticles.hide()
		$BackgroundParticles.emitting = false
		$InfoMenu/Optimize2.text = "Particles disabled"

func _on_info_menu_pressed() -> void:
	$PauseMenu.hide()
	from_pause = true
	$InfoMenu.show()

func _enter_fever_mode() -> void:
	if fever_mode_activated:
		return
	
	fever_mode_activated = true
	fever_mode = true
	
	for wbc in get_tree().get_nodes_in_group("wbc"):
		wbc.wbc_speed *= 1.7
		print("wbc speed: ", wbc.wbc_speed)
		player.player_speed = wbc.wbc_speed - 5
	
	wbc_spawn_timer.wait_time = 4
	
	player.player_speed /= 1.3
	print("player speed: ", player.player_speed)

func _exit_fever_mode() -> void:
	if not fever_mode_activated:
		return
	
	fever_mode_activated = false
	fever_mode = false
	
	for wbc in get_tree().get_nodes_in_group("wbc"):
		wbc.wbc_speed /= 1.7
		print("wbc speed: ", wbc.wbc_speed)
		player.player_speed = player.init_speed
	
	wbc_spawn_timer.wait_time = default_wbc_spawn_timer_value
	
	print("player speed: ", player.player_speed)
	print("the body has cooled down...")
