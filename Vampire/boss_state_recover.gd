class_name BossRecover
extends BossState

@export var recover_time: float = 0.55
@onready var chase: BossState = $"../chase"

var t: float = 0.0

func Enter() -> void:
	t = recover_time
	boss.set_charge_active(false)

func Process(delta: float) -> BossState:
	t -= delta
	if t <= 0.0:
		return chase
	return null

func Physics(delta: float) -> BossState:
	# During recover, keep distance gently (no attacks)
	if not boss.has_target():
		boss.steer_toward(Vector2.ZERO, delta)
		return null

	var desired := boss.desired_keep_distance_velocity() * 0.7
	boss.steer_toward(desired, delta)

	if desired.length_squared() > 1.0:
		boss.play_move_anim(desired)
	else:
		boss.pause_anim()

	return null
