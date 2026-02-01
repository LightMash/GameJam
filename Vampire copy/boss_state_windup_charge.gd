class_name BossWindupCharge
extends BossState

@export var windup_time: float = 0.6
@onready var charge: BossState = $"../charge"
@onready var chase: BossState = $"../chase"

var t: float = 0.0

func Enter() -> void:
	t = windup_time
	boss.stop_motion()
	boss.set_charge_active(false)
	boss.clear_end_charge_request()

	# lock a “smart” target (slight prediction)
	boss.set_charge_target(boss.predicted_target_pos())

	# play dash animation as a tell
	boss.play_attack_dash(boss.get_charge_direction())

func Process(delta: float) -> BossState:
	if not boss.has_target():
		return chase

	t -= delta
	if t <= 0.0:
		return charge
	return null

func Physics(_delta: float) -> BossState:
	boss.velocity = Vector2.ZERO
	return null
