class_name State_Attack
extends State

var attacking: bool = false

@export var attack_sound: AudioStream
@export_range(1, 20, 0.5) var decelerate_speed: float = 0.0

@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var hurt_box: HurtBox = $"../../Interactions/HurtBox"

# Optional (won't crash if you don't have them)
@onready var attack_anim: AnimationPlayer = get_node_or_null("../../Sprite2D/AttackEffectSprite/AnimationPlayer")
@onready var audio: AudioStreamPlayer2D = get_node_or_null("../../Audio/AudioStreamPlayer2D")

func Enter() -> void:
	attacking = true
	hurt_box.monitoring = false

	# Face cursor before attacking
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
	hurt_box.monitoring = true

func Exit() -> void:
	if animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	hurt_box.monitoring = false

func Process(_delta: float) -> State:
	# If you still have decelerate_speed > 0, this slows you.
	# Keep it at 0 to remove slowdown.
	player.velocity -= player.velocity * decelerate_speed * _delta

	if not attacking:
		return idle if player.direction == Vector2.ZERO else walk
	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack(_anim_name: String) -> void:
	attacking = false
