class_name State_Attack
extends State

var attacking: bool = false

# Set this to 0 to remove the slowdown while attacking
@export var decelerate_speed: float = 0.0

@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

# Optional nodes (won't crash if you don't have them)
@export var attack_sound: AudioStream
@onready var attack_anim: AnimationPlayer = get_node_or_null("../../Sprite2D/AttackEffectSprite/AnimationPlayer")
@onready var audio: AudioStreamPlayer2D = get_node_or_null("../../Audio/AudioStreamPlayer2D")

func Enter() -> void:
	attacking = true
<<<<<<< Updated upstream
	hurt_box.monitoring = false
=======
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = false
>>>>>>> Stashed changes

	# Attack faces cursor
	player.setFacingToMouse()

	player.UpdateAnimation("attack")
	if not animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.connect(EndAttack)

	if attack_anim:
		attack_anim.play("attack_" + player.AnimDirection())

	if audio and attack_sound:
		audio.stream = attack_sound
		audio.pitch_scale = randf_range(0.9, 1.1)
		audio.play()

	await get_tree().create_timer(0.075).timeout
	if not attacking:
		return

func Exit() -> void:
	if animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
<<<<<<< Updated upstream
	hurt_box.monitoring = false
=======
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = true
>>>>>>> Stashed changes

func Process(_delta: float) -> State:
	# Slowdown line removed (decelerate_speed is 0 anyway)
	# player.velocity -= player.velocity * decelerate_speed * _delta

	if not attacking:
		return idle if player.direction == Vector2.ZERO else walk
	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack(_anim_name: String) -> void:
	attacking = false
