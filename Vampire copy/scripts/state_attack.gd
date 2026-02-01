class_name State_Attack
extends State

var attacking: bool = false

# Set this to 0 to remove the slowdown while attacking
@export var decelerate_speed: float = 0.0

@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"


@onready var attack_anim: AnimationPlayer = get_node_or_null("../../Sprite2D/AttackEffectSprite/AnimationPlayer")


func Enter() -> void:
	attacking = true
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = false

	# Attack faces cursor
	player.setFacingToMouse()

	player.UpdateAnimation("attack")
	if not animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.connect(EndAttack)

	if attack_anim:
		attack_anim.play("attack_" + player.AnimDirection())



	await get_tree().create_timer(0.075).timeout
	if not attacking:
		return

func Exit() -> void:
	if animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = true

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
