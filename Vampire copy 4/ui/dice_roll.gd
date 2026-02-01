extends Sprite2D   # THIS is the rolling dice sprite

@onready var dice_sound = $dice_sound
@onready var roll_anim: AnimationPlayer = $AnimationPlayer
@onready var animSprite = $"."
@onready var dice1 = $"../D1"
@onready var dice2 = $"../D2"
@onready var dice3 = $"../D3"
@onready var dice4 = $"../D4"
@onready var dice5 = $"../D5"
@onready var dice6 = $"../D6"

var last_day := -1
var dice_result := 1

func _ready():
	NightCycleManager.time_tick.connect(_on_time_tick)

func _on_time_tick(day: int, hour: int, minute: int):
	if day != last_day:
		last_day = day
		start_dice_roll()

func start_dice_roll():
	animSprite.visible = true
	#turn off all the dices
	dice1.visible = false
	dice2.visible = false
	dice3.visible = false
	dice4.visible = false
	dice5.visible = false
	dice6.visible = false
	
	dice_result = randi_range(1, 6)

	roll_anim.play("dice")
	dice_sound.play()
	await get_tree().create_timer(1.2).timeout
	animSprite.visible = false

	if dice_result == 1 :
		dice1.visible = true
		gameState.player_is_hunting = false

	elif dice_result == 2 : 
		dice2.visible = true
		gameState.player_is_hunting = true

	elif dice_result == 3 : 
		dice3.visible = true
		gameState.player_is_hunting = false

	elif dice_result == 4 : 
		dice4.visible = true
		gameState.player_is_hunting = true

	elif dice_result == 5 : 
		dice5.visible = true
		gameState.player_is_hunting = false

	elif dice_result == 6 : 
		dice6.visible = true
		gameState.player_is_hunting = true
