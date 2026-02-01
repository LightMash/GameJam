class_name State_Emote extends State

@onready var idle: State_Idle = $"../idle"
@onready var walk: State = $"../walk"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var emote_sound = $emote_sound

var emoting := false

func Enter() -> void:
	player.velocity = Vector2.ZERO

	# Play ONE fixed emote animation
	animation_player.play("emote")
	emote_sound.play()

	if not animation_player.animation_finished.is_connected(EndEmote):
		animation_player.animation_finished.connect(EndEmote)

	emoting = true

func Exit() -> void:
	if animation_player.animation_finished.is_connected(EndEmote):
		animation_player.animation_finished.disconnect(EndEmote)

	emoting = false

func Process(_delta: float) -> State:
	player.velocity = Vector2.ZERO

	if not emoting:
		if player.direction == Vector2.ZERO:
			return idle
		return walk

	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	return null

func EndEmote(_anim_name: StringName) -> void:
	# Only end when the emote finishes
	if String(_anim_name) == "emote":
		emoting = false
