class_name BossHitboxesHost
extends Node2D

@onready var boss: Node = $".."
@onready var boss_sprite: Sprite2D = boss.get_node_or_null("Sprite2D") as Sprite2D

var _base_scale_x: float

func _ready() -> void:
	_base_scale_x = abs(scale.x)

func _process(_delta: float) -> void:
			   # follow the horse facing (your HorseBoss flips sprite using sprite.scale.x = -1/1)
	if boss_sprite == null:
		return

	var facing_sign := -1.0 if boss_sprite.scale.x < 0.0 else 1.0
	scale.x = _base_scale_x * facing_sign
