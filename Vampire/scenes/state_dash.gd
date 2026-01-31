<<<<<<< Updated upstream
extends Node
=======
class_name State_Dash extends State

@export var dash_speed: float = 350
@export var dash_duration: float = 0.7
@export var dash_cooldown: float = 4


@onready var idle: State_Idle = $"../idle"
@onready var walk: State = $"../walk"
@onready var hurt_box: Area2D = $"../../Interactions/HurtBox"  # adjust path if needed

var dash_dir: Vector2 = Vector2.ZERO
var time_left: float = 0.0
var can_dash: bool = true

func Enter() -> void:
	if not can_dash:
		return

	can_dash = false
	time_left = dash_duration

	
	if player.direction != Vector2.ZERO:
		player.setDirection()  
		dash_dir = player.direction.normalized()
	else:
		dash_dir = player.cardinal_direction.normalized()

	
	player.UpdateAnimation("dash")

	
	if is_instance_valid(hurt_box):
		hurt_box.monitoring = false

	
	_start_cooldown()

func Exit() -> void:

	player.velocity = Vector2.ZERO
>>>>>>> Stashed changes


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
