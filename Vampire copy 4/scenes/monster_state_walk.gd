class_name MonsterState
extends Node

var monster: CharacterBody2D

func Enter() -> void: pass
func Exit() -> void: pass
func Process(_delta: float) -> MonsterState: return null
func Physics(_delta: float) -> MonsterState: return null
func HandleInput(_event: InputEvent) -> MonsterState: return null
