class_name HurtBox
extends Area2D

@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Player body uses HitBox.gd already
	if area.is_in_group("enemy_hitbox"):
		print("taking damage!")
