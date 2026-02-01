class_name EnemyInteractionsHost
extends Node2D

@onready var enemy = $".."   # parent enemy node

# Call this whenever the enemy direction changes
func UpdateDirection(dir: Vector2) -> void:
	match dir:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			pass
