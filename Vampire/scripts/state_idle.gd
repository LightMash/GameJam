class_name State_Idle extends State

@onready var walk : State = $"../walk"
@onready var attack: Node = $"../attack"
<<<<<<< Updated upstream
@onready var dash: Node = $"../dash"
=======
@onready var dash: State = $"../dash"
>>>>>>> Stashed changes

func Enter() -> void:
	player.UpdateAnimation("idle")

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	# IMPORTANT: keep direction updated while idle
	player.setDirection()

	if player.direction != Vector2.ZERO:
		return walk

	player.velocity = Vector2.ZERO
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
