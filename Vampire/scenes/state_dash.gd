class_name State_Dash extends State

@export var dash_speed: float = 350.0
@export var dash_duration: float = 0.12
@export var dash_cooldown: float = 0.35

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


	if is_instance_valid(hurt_box):
		hurt_box.monitoring = true

func Process(delta: float) -> State:
	time_left -= delta

	if time_left <= 0.0:
		
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk

	return null

func Physics(_delta: float) -> State:
	
	player.velocity = dash_dir * dash_speed
	return null

func HandleInput(_event: InputEvent) -> State:

	return null

func _start_cooldown() -> void:
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
