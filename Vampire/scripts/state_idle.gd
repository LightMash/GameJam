class_name State_Idle extends State

@onready var walk : State = $"../walk"
@onready var attack: State = $"../attack"
@onready var dash: State = $"../dash"
@onready var emote: State_Emote = $"../emote"

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

func HandleInput(event: InputEvent) -> State:
	if event.is_action_pressed("emote"):
		return emote
	if event.is_action_pressed("dash"):
		return dash
	if event.is_action_pressed("attack"):
		return attack
	return null
