extends CharacterBody2D

@export var movement_speed: float = 20.0
@onready var player: Player = get_tree().get_first_node_in_group("player") as Player

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
		if player == null:
			velocity = Vector2.ZERO
			return

	var direction: Vector2 = global_position.direction_to(player.global_position) # normalized
	velocity = direction * movement_speed
	move_and_slide()
