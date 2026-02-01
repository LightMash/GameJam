class_name BossStateCharge
extends BossState


@export var charge_time: float = 0.95
@onready var recover: BossState = $"../recover"
@onready var gallopingSound = $Galloping

var t: float = 0.0
var dir: Vector2 = Vector2.ZERO

func Enter() -> void:
	gallopingSound.autoplay = true
	gallopingSound.play()
	t = charge_time
	boss.set_charge_active(true)
	boss.clear_end_charge_request()

	dir = boss.get_charge_direction()
	if dir == Vector2.ZERO:
		dir = boss.dir_to_target()

	boss.play_attack_dash(dir)
	await get_tree().create_timer(1).timeout
	gallopingSound.autoplay = false

func Process(delta: float) -> BossState:
	t -= delta

	if boss.charge_force_end or t <= 0.0:
		boss.set_charge_active(false)
		boss.start_charge_cooldown()
		boss.clear_end_charge_request()
		return recover

	return null

func Physics(delta: float) -> BossState:
	# ramp speed instead of snapping instantly
	var desired := dir * boss.charge_speed
	boss.steer_toward(desired, delta, boss.charge_accel)
	return null
