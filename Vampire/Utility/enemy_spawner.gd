extends Node2D

@export var spawns: Array[Spawn_info] = []
@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

var time: int = 0

func _on_timer_timeout() -> void:
	time += 1

	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			return

	for info in spawns:
		if info == null:
			continue

		if time < info.time_start or time > info.time_end:
			continue

		if info.monster == null:
			push_warning("Spawn_info missing monster scene in Inspector!")
			continue

		info.spawn_delay_counter += 1
		if info.spawn_delay_counter < info.monster_spawn_delay:
			continue

		info.spawn_delay_counter = 0

		for n in range(info.monster_num):
			var enemy = info.monster.instantiate()
			enemy.global_position = get_random_position()
			add_child(enemy)

func get_random_position() -> Vector2:
	var vpr = get_viewport_rect().size * randf_range(0.1, 0.5)

	var top_left     = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right    = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left  = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)

	var pos_side = ["up", "down", "right", "left"].pick_random()

	var spawn_pos1 := Vector2.ZERO
	var spawn_pos2 := Vector2.ZERO

	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left

	return Vector2(
		randf_range(spawn_pos1.x, spawn_pos2.x),
		randf_range(spawn_pos1.y, spawn_pos2.y)
	)
