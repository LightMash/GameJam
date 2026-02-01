extends CharacterBody2D

@export var movement_speed: float = 20.0
@onready var player: Player = get_tree().get_first_node_in_group("player") as Player
@onready var health = 3

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
		if player == null:
			velocity = Vector2.ZERO
			return

	var direction: Vector2
	if gameState.player_is_hunting == false :
		direction = global_position.direction_to(player.global_position)
	else :
		direction = player.global_position.direction_to(global_position)
	velocity = direction * movement_speed
	move_and_slide()

func TakeDamage():
	health = health -1
	if health <= 0:
		Die()
	print("enemy health : ", health)

func Die():
	print ("enemy died!")
	queue_free()
	
func _on_area_2d_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		area.TakeDamage()
