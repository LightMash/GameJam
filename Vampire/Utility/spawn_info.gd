extends Resource
class_name Spawn_info

@export var time_start: int = 0
@export var time_end: int = 999
@export var monster: PackedScene       
@export var monster_num: int = 1
@export var monster_spawn_delay: int = 5

var spawn_delay_counter: int = 0
