class_name HitBoxPlayer
extends Area2D
func _ready():
	add_to_group("player_hitbox")

func TakeDamage() -> void:
	get_parent().get_parent().TakeDamage()
