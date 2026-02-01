extends Area2D

func _ready():
	add_to_group("enemy_hitbox")

func TakeDamage() -> void:
	get_parent().TakeDamage()
