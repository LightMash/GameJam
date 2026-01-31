extends CharacterBody2D

@export var movement_speed =20.0

@onready var player = get_tree().get_first_node_in_group("player")

func_physics_process(_delta):
	var direction + global_position.direction_to(player_global position)
	velocity = direction *movement_speed
	move_and_slide()
