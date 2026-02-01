class_name State_Attack
extends State

var attacking: bool = false

# If you want to control speed while attacking, set this.
# If set to -1, it will use the walk state's move_speed automatically.
@export var attack_move_speed: float = -1.0

# Keep facing the mouse while attacking (attack direction = mouse)
@export var face_mouse_while_attacking: bool = true

# Stops any leftover drift when you release WASD during attack
@export var stop_when_no_input: bool = true

@onready var walk: State_Walk = $"../walk"
@onready var idle: State = $"../idle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_sound = $attack_sound
@onready var attack_anim: AnimationPlayer = get_node_or_null("../../Sprite2D/AttackEffectSprite/AnimationPlayer")
@onready var animSw: AnimationPlayer = $"../../Sprite2D/swoosheffect/AnimationPlayer"
@onready var swooshEffect = $"../../Sprite2D/swoosheffect"

func Enter() -> void:
	
	
	attacking = true
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = false

	# Attack faces cursor (mouse), movement stays WASD
	if face_mouse_while_attacking:
		player.setFacingToMouse()

	player.UpdateAnimation("attack")
	animSw.play("swoosh_" + player.AnimDirection())
	attack_sound.play()

	if not animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.connect(EndAttack)

	if attack_anim:
		attack_anim.play("attack_" + player.AnimDirection())

	# (kept from your code)
	await get_tree().create_timer(0.075).timeout
	if not attacking:
		return

func Exit() -> void:
	if animation_player.animation_finished.is_connected(EndAttack):
		animation_player.animation_finished.disconnect(EndAttack)

	attacking = false
	$"../../Interactions/HurtBox/CollisionShape2D".disabled = true

func Process(_delta: float) -> State:
	# Keep attack direction toward mouse even while moving with WASD
	if face_mouse_while_attacking:
		# If direction changed (mouse crossed another side), refresh attack anim direction
		if player.setFacingToMouse():
			player.UpdateAnimation("attack")

	# Movement while attacking = WASD
	var speed := attack_move_speed
	if speed < 0.0:
		speed = walk.move_speed

	player.velocity = player.direction * speed

	if stop_when_no_input and player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO

	if not attacking:
		return idle if player.direction == Vector2.ZERO else walk

	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	return null

func EndAttack(_anim_name: String) -> void:
	attacking = false
