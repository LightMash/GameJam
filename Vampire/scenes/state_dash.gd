<<<<<<< Updated upstream
extends Node
=======
class_name State_Dash extends State

<<<<<<< Updated upstream
@export var dash_speed: float = 350
@export var dash_duration: float = 0.7
@export var dash_cooldown: float = 4

=======
@export var dash_speed: float = 200
@export var dash_duration: float = 0.7
@export var dash_cooldown: float = 3.5
>>>>>>> Stashed changes

@onready var idle: State_Idle = $"../idle"
@onready var walk: State = $"../walk"
@onready var hurt_box: Area2D = $"../../Interactions/HurtBox" # adjust if your path differs

var dash_dir: Vector2 = Vector2.ZERO
var time_left: float = 0.0
var can_dash: bool = true

func Enter() -> void:
	if not can_dash:
		return

	can_dash = false
	time_left = dash_duration

	# Update facing (cardinal_direction) based on current input, if any
	player.setDirection()

	# STRICT 4-DIRECTION DASH (no diagonals)
	dash_dir = player.cardinal_direction.normalized()

	# Plays: dash_up / dash_down / dash_side automatically
	player.UpdateAnimation("dash")

	# i-frames during dash (optional)
	if is_instance_valid(hurt_box):
		hurt_box.monitoring = false

	_start_cooldown()

func Exit() -> void:
	player.velocity = Vector2.ZERO
>>>>>>> Stashed changes

<<<<<<< Updated upstream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
=======
	if is_instance_valid(hurt_box):
		hurt_box.monitoring = true
>>>>>>> Stashed changes


<<<<<<< Updated upstream
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
=======
	if time_left <= 0.0:
		# decide where to go after dash
		if player.direction == Vector2.ZERO:
			return idle
		return walk

	return null

func Physics(_delta: float) -> State:
	# Player._physics_process already calls move_and_slide()
	player.velocity = dash_dir * dash_speed
	return null

func HandleInput(_event: InputEvent) -> State:
	# ignore inputs during dash
	return null

func _start_cooldown() -> void:
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
>>>>>>> Stashed changes
