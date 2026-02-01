class_name BossMelee
extends BossState

@export var total_time: float = 0.55
@export var windup_time: float = 0.12
@export var active_time: float = 0.18

@onready var chase: BossState = $"../chase"

var t: float = 0.0

func Enter() -> void:
	t = total_time
	boss.stop_motion()
	boss.set_melee_active(false)
	boss.play_attack_side(boss.dir_to_target())

func Process(delta: float) -> BossState:
	var elapsed := total_time - t

	# enable hitbox only in the “active” window
	if elapsed >= windup_time and elapsed < windup_time + active_time:
		boss.set_melee_active(true)
	else:
		boss.set_melee_active(false)

	t -= delta
	if t <= 0.0:
		boss.set_melee_active(false)
		boss.start_melee_cooldown()
		return chase

	return null

func Physics(_delta: float) -> BossState:
	boss.velocity = Vector2.ZERO
	return null
