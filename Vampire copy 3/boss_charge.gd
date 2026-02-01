class_name BossCharge
extends BossState

@export var charge_time: float = 0.9
@onready var recover: BossState = $"../recover"

var t: float = 0.0
var dir: Vector2 = Vector2.ZERO

func Enter() -> void:
	t = charge_time
	boss.set_charge_active(true)
	boss.clear_end_charge_request()

	dir = boss.get_charge_direction()
	if dir == Vector2.ZERO:
		dir = boss.dir_to_target()

	boss.play_attack_dash(dir)

func Process(delta: float) -> BossState:
	t -= delta

	if boss.charge_force_end or t <= 0.0:
		boss.set_charge_active(false)
		boss.start_charge_cooldown()
		boss.clear_end_charge_request()
		return recover

	return null

func Physics(_delta: float) -> BossState:
	boss.velocity = dir * boss.charge_speed
	return null
