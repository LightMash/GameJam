extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_day := -1
var dice_result := 1


func _ready() -> void:
	NightCycleManager.time_tick.connect(_on_time_tick)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Show initial dice face (face 1)
	show_dice_face(1)

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	# Only trigger at the START of a new day
	if day != last_day:
		last_day = day
		start_dice_roll()

func start_dice_roll() -> void:
	# Decide the result FIRST
	dice_result = randi_range(1, 6)
	
	# Play roll animation
	animation_player.play("dice")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "dice":
		show_final_dice()

func show_final_dice() -> void:
	# Show the final dice result
	show_dice_face(dice_result)

func show_dice_face(face_number: int) -> void:
	# Based on the animation using row 5 (frame_coords y=5)
	# Dice faces 1-6 should be in row 5, columns 0-5
	# For a 13 hframes x 14 vframes spritesheet:
	# frame = y * hframes + x = 5 * 13 + (face_number - 1)
	frame = 5 * 13 + (face_number - 1)  # Frames 65-70 for dice 1-6
