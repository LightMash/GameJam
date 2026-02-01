extends Node

## Boss Spawner - Spawns the horse boss on day 3

@export var boss_scene: PackedScene
@export var spawn_position: Vector2 = Vector2(400, 200)
@export var spawn_day: int = 3
@onready var bossMusic = $BossMusic

var boss_spawned: bool = false
var boss_instance: Node = null

func _ready() -> void:
	# Connect to the NightCycleManager day signal
	if NightCycleManager:
		NightCycleManager.time_tick_day.connect(_on_day_changed)
	else:
		push_error("BossSpawner: NightCycleManager not found!")

func _on_day_changed(day: int) -> void:
	# Spawn boss once on day 3
	if day >= spawn_day and not boss_spawned:
		spawn_boss()

func spawn_boss() -> void:
	bossMusic.play()
	if not boss_scene:
		push_error("BossSpawner: No boss scene assigned!")
		return
	
	if boss_spawned:
		return
	
	# Instance the boss
	boss_instance = boss_scene.instantiate()
	
	# Set position
	if boss_instance is Node2D:
		boss_instance.global_position = spawn_position
	
	# Add to parent (map)
	get_parent().add_child(boss_instance)
	
	boss_spawned = true
	print("Boss spawned on day ", NightCycleManager.current_day, " at position ", spawn_position)
	
	# Optional: Connect to boss death to track if player defeated it
	if boss_instance.has_signal("died"):
		boss_instance.died.connect(_on_boss_died)

func _on_boss_died() -> void:
	print("Boss has been defeated!")
	boss_instance = null
