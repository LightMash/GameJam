class_name Health extends Node

@export var max_hp: int = 5
var hp: int

signal HPChanged(current: int, max: int)
signal Died

@export var invincible_time : float = 0.6
var invincible: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	HPChanged.emit(hp,max_hp) # Replace with function body.
func TakeDamage(amount:int) -> void:
	if invincible:
		return
	hp = max(0, hp-amount)
	HPChanged.emit(hp, max_hp)
	
	if hp <= 0:
		Died.emit()
		return
	_start_iframes()
func _start_iframes()-> void:
	invincible = true
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
