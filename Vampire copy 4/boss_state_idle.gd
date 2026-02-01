class_name BossIdle
extends BossState

@export var idle_time: float = 0.2
@onready var chase: BossState = $"../chase"

var t: float = 0.0

func Enter() -> void:
	t = idle_time
	boss.stop_motion()
	boss.pause_anim()

func Process(delta: float) -> BossState:
	if not boss.has_target():
		return null
	t -= delta
	if t <= 0.0:
		return chase
	return null
