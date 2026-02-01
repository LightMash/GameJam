class_name BossBackoff
extends BossState

@export var backoff_time: float = 0.75
@onready var windup: BossState = $"../windup_charge"
@onready var chase: BossState = $"../chase"

var t: float = 0.0

func Enter() -> void:
	t = backoff_time
	boss.clear_end_charge_request()

func Process(delta: float) -> BossState:
	if not boss.has_target():
		return chase

	t -= delta
	if t <= 0.0:
		return windup if boss.charge_ready() else chase
	return null

func Physics(delta: float) -> BossState:
	if not boss.has_target():
		boss.steer_toward(Vector2.ZERO, delta)
		return null

	var away := -boss.dir_to_target()
	var desired := away * boss.backoff_speed
	boss.steer_toward(desired, delta)

	boss.play_move_anim(desired)
	return null
