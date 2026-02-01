class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var health: Health = $Health

signal DirectionChanged(new_direction: Vector2)

func _ready():
	state_machine.Initialize(self)
	pass

func _process(delta):
	direction = Vector2(
		Input.get_axis("left","right"),
		Input.get_axis("up","down")
	).normalized()
	pass

func _physics_process(delta):
	move_and_slide()

func setDirection() -> bool:
	var new_dir: Vector2 = cardinal_direction

	if direction == Vector2.ZERO:
		return false
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	DirectionChanged.emit(new_dir)
	sprite_2d.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

# NEW: face the cursor (used for attacking)
func setFacingToMouse() -> bool:
	var v: Vector2 = get_global_mouse_position() - global_position
	if v.length_squared() < 0.0001:
		return false

	var new_dir: Vector2 = cardinal_direction
	if absf(v.x) > absf(v.y):
		new_dir = Vector2.RIGHT if v.x > 0 else Vector2.LEFT
	else:
		new_dir = Vector2.DOWN if v.y > 0 else Vector2.UP

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	DirectionChanged.emit(new_dir)
	sprite_2d.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func UpdateAnimation(state: String) -> void:
	animation_player.play(state + "_" + AnimDirection())
	pass

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
