class_name BossChase
extends BossState

@onready var idle: BossState = $"../idle"
@onready var backoff: BossState = $"../backoff"
@onready var melee: BossState = $"../melee"

func Process(_delta: float) -> BossState:
	if not boss.has_target():
		return idle

	var d := boss.distance_to_target()

	# If player pushes too close, do the “smart” backoff -> charge pattern
	if d <= boss.too_close_range and boss.charge_ready():
		return backoff

	# If close enough and melee is ready, swipe
	if d <= boss.melee_range and boss.melee_ready():
		return melee

	return null

func Physics(_delta: float) -> BossState:
	if not boss.has_target():
		boss.velocity = Vector2.ZERO
		return null

	var d := boss.distance_to_target()
	var dir := boss.dir_to_target()

	# Approach until preferred distance, then pause (no idle anim needed)
	if d > boss.preferred_range:
		boss.velocity = dir * boss.move_speed
		boss.play_move_anim(dir)
	else:
		boss.velocity = Vector2.ZERO
		boss.pause_anim()

	return null
