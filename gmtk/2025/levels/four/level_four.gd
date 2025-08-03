# please spare me for not using components
# it is currently 8:31pm as I am writing this 
# and I have less than 3 hours left before submission closes
class_name LevelFour extends Level


@export var dog_cooldown: float = 2.0


var can_pet: bool = false
var can_equip: bool = false

var dog_on_cooldown: bool = false

var sword_equipped: bool = false
var has_pet_dog: bool = false


@onready var shadow: AnimatedSprite2D = $Dog/DogShadow
@onready var dog: AnimatedSprite2D = $Dog/DogMain
@onready var dog_bark: AudioStreamPlayer2D = $Dog/DogBark
@onready var dog_cry: AudioStreamPlayer2D = $Dog/DogCry
@onready var heart: Sprite2D = $Dog/Heart

@onready var sword_shadow: Sprite2D = $Sword/SwordShadow
@onready var sword_main: Sprite2D = $Sword/SwordMain

@onready var sword_interactable: Area2D = $Sword/InteractableArea


func _ready() -> void:
	super()
	dog.play("WAG")
	shadow.play("WAG")

	player.sword(false)
	$BlackScreen.hide()


func _physics_process(delta: float) -> void:
	if can_pet and Input.is_action_just_pressed("interact") and not dog_on_cooldown:
		_pet_dog()
	elif can_equip and Input.is_action_just_pressed("interact"):
		_equip_sword()


func _pet_dog() -> void:
	dog_on_cooldown = true

	if sword_equipped:
		if has_pet_dog:
			_happy_dog()
		else:
			_sad_dog()
			return

	has_pet_dog = true
	heart.show()
	dog_bark.play()
	dog.play("LOVE")
	shadow.play("LOVE")

	await get_tree().create_timer(dog_cooldown).timeout

	heart.hide()
	dog.play("WAG")
	shadow.play("WAG")

	dog_on_cooldown = false


func _equip_sword() -> void:
	sword_interactable.monitoring = false
	sword_interactable.monitorable = false

	sword_equipped = true

	sword_shadow.hide()
	sword_main.hide()
	player.sword(true)

	display_screen.display_text("WHY IS THERE A SWORD THERE?! PUT THAT DOWN!")


func _happy_dog() -> void:
	player.sword(false)
	await get_tree().create_timer(1.0).timeout
	display_screen.correct()


func _sad_dog() -> void:
	$BlackScreen.show()
	AudioManager.stream_paused = true
	await get_tree().create_timer(1.5).timeout
	dog_cry.play()
	await dog_cry.finished
	await get_tree().create_timer(3.0).timeout
	player.sword(false)
	$BlackScreen.hide()
	GameManager.next_level()
	AudioManager.stream_paused = false


func _on_dog_area_entered(player: Player) -> void:
	can_pet = true


func _on_dog_area_exited(player: Player) -> void:
	can_pet = false


func on_sword_area_entered(player: Player) -> void:
	can_equip = true


func _on_sword_area_exited(body: Node2D) -> void:
	can_equip = false
