class_name BossState
extends Node

static var boss: HorseBoss

func Enter() -> void:
	pass

func Exit() -> void:
	pass

func Process(_delta: float) -> BossState:
	return null

func Physics(_delta: float) -> BossState:
	return null
