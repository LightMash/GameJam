class_name State_Attack extends State

var attacking: bool = false
@export_range(1,20,0.5) var decelerate_speed: float = 5.0
@onready var walk: State = $"../walk"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var idle: State_Idle = $"../idle"
@onready var hurt_box: HurtBox = $"../../Interactions/HurtBox"
@onready var hit_box: HitBox = $"../../Interactions/HitBox"

func Enter() -> void:
	player.UpdateAnimation("attack")
	animation_player.animation_finished.connect(EndAttack)
	#attack.play("attack_" + player.AnimDirection())
	attacking = true
	
	await get_tree().create_timer(0.075).timeout
	hurt_box.monitoring = true
# Called when the node enters the scene tree for the first time.
func Exit() -> void: # what happens wjen the player exits this state?
	animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	hurt_box.monitoring = false
	pass
	
func Process( _delta: float ) -> State: # what happens during the _process update in this state?	
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null
	
func Physics( _delta : float) -> State: #What happens during the _physics_process update in this state
	return null


func HandleInput( _event: InputEvent ) -> State: # What happens with input events in this state
	return null
	
func EndAttack(_newAnimName: String) -> void:
	attacking = false
