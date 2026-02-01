class_name BossChase
extends BossState

@export var close_melee_chance: float = 0.45 # 0..1 (45% chance)
var _rng := RandomNumberGenerator.new()

@onready var idle: BossState = $"../idle"
@onready var backoff: BossState = $"../backoff"
@onready var melee: BossState = $"../melee"

func _ready() -> void:
	_rng.randomize()

func Process(_delta: float) -> BossState:
	if not boss.has_target():
		return idle

	var d := boss.distance_to_target()

	# If player is too close, SOMETIMES try melee
	if d <= boss.too_close_range and boss.melee_ready():
		if _rng.randf() < close_melee_chance or not boss.charge_ready():
			return melee

	# Otherwise keep your “smart” backoff -> charge pattern
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

	if d > boss.preferred_range:
		boss.velocity = dir * boss.move_speed
		boss.play_move_anim(dir)
	else:
		boss.velocity = Vector2.ZERO
		boss.pause_anim()

	return null
