class_name EndScreen extends Level


@export var gmtk_float_speed: float = 2.0
@export var gmtk_float_strength: float = 5.0


var gmtk_float_timer: float = 0.0
var gmtk_base_position: Vector2 = Vector2.ZERO
var gmtk_base_rotation: float = 0.0

var times: Array[float] = []

var can_pet_dog: bool = false
var dog_on_cooldown: bool = false
var dog_cooldown: float = 1.5


@onready var dog_sprite: AnimatedSprite2D = $Dog/DogMain
@onready var dog_shadow: AnimatedSprite2D = $Dog/DogShadow
@onready var dog_bark: AudioStreamPlayer2D = $Dog/DogBark
@onready var dog_heart: Sprite2D = $Dog/Heart

@onready var gmtk_2025_logo: Sprite2D = $EndScreenStuff/GMTK
@onready var times_label: Label = $EndScreenStuff/TimesLabel


func _ready() -> void:
	player.sword(false)

	_add_times()

	gmtk_base_position = gmtk_2025_logo.global_position
	gmtk_base_rotation = gmtk_2025_logo.rotation_degrees

	dog_sprite.play("WAG")
	dog_shadow.play("WAG")
	dog_heart.hide()


func _physics_process(delta: float) -> void:
	gmtk_float_timer += get_physics_process_delta_time() * gmtk_float_speed

	# float animation
	var offset_x := sin(float_timer) * gmtk_float_strength
	var offset_y := cos(float_timer) * gmtk_float_strength
	gmtk_2025_logo.position.x = gmtk_base_position.x + offset_x
	gmtk_2025_logo.position.y = gmtk_base_position.y + offset_y

	# slight rotation
	gmtk_2025_logo.rotation_degrees = base_rotation + sin(gmtk_float_timer * 0.8) * rotate_strength

	if can_pet_dog and Input.is_action_just_pressed("interact") and not dog_on_cooldown:
		_pet_dog()


func _pet_dog() -> void:
	dog_on_cooldown = true
	dog_sprite.play("LOVE")
	dog_shadow.play("LOVE")
	dog_heart.show()

	dog_bark.play()

	await get_tree().create_timer(dog_cooldown).timeout

	dog_heart.hide()
	dog_sprite.play("WAG")
	dog_shadow.play("WAG")
	dog_on_cooldown = false



func _add_times() -> void:
	var raw_times := GameManager.get_times()
	var result_text := ""

	for i in range(raw_times.size()):
		var formatted_time := GameManager.format_time(raw_times[i])
		result_text += "Level %d: %s\n" % [i + 1, formatted_time]

	times_label.text = result_text.strip_edges()


func _on_dog_area_entered(body: Node2D) -> void:
	can_pet_dog = true


func _on_dog_area_exited(body: Node2D) -> void:
	can_pet_dog = false
