class_name State_Walk extends State

@export var move_speed: float = 100.0
@onready var idle: State = $"../idle"
@onready var attack: Node = $"../attack"
<<<<<<< Updated upstream
@onready var dash: Node = $"../dash"
=======
@onready var dash: State = $"../dash"
>>>>>>> Stashed changes

func Enter() -> void:
	player.UpdateAnimation("walk")

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	# IMPORTANT: update direction first
	if player.setDirection():
		player.UpdateAnimation("walk")

	if player.direction == Vector2.ZERO:
		return idle

	player.velocity = player.direction * move_speed
	return null

func Physics(_delta: float) -> State:
	return null
<<<<<<< Updated upstream
	
func HandleInput( _event: InputEvent ) -> State: 
	if _event.is_action_pressed("dash"):
		return dash
	if _event.is_action_pressed("attack"):
=======

func HandleInput(event: InputEvent) -> State:
	if event.is_action_pressed("dash"):
		return dash
	if event.is_action_pressed("attack"):
>>>>>>> Stashed changes
		return attack
	return null
