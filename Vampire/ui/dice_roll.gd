extends Sprite2D

@onready var animation_player: AnimationPlayer = $DiceRollAnimationPlayer

# Change paths to match your project
@export var dice_faces := [
	preload("res://assets/dice/dice_1.png")
]

var last_day := -1
var dice_result := 1


func _ready() -> void:
	NightCycleManager.time_tick.connect(_on_time_tick)
	animation_player.animation_finished.connect(_on_animation_finished)

	# Optional: show something on day 0
	texture = dice_faces[0]

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	# Only trigger at the START of a new day
	if day != last_day:
		last_day = day
		start_dice_roll()

func start_dice_roll() -> void:
	# Decide the result FIRST
	dice_result = randi_range(1, 6)

	# Play roll animation
	animation_player.play("dice_roll")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "dice_roll":
		show_final_dice()

func show_final_dice() -> void:
	# Dice faces array is 0-based, dice is 1–6
	#texture = dice_faces[dice_result - 1]
	texture = dice_faces[0]
