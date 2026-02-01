class_name BossStateMachine
extends Node

@export var initial_state: NodePath = NodePath("chase")
var current_state: BossState

func Initialize(b: HorseBoss) -> void:
	BossState.boss = b
	current_state = get_node_or_null(initial_state) as BossState
	if current_state == null:
		push_error("BossStateMachine: initial_state is invalid: " + str(initial_state))
		return
	current_state.Enter()

func Update(delta: float) -> void:
	if current_state == null:
		return
	var next := current_state.Process(delta)
	if next != null:
		_change_state(next)

func PhysicsUpdate(delta: float) -> void:
	if current_state == null:
		return
	var next := current_state.Physics(delta)
	if next != null:
		_change_state(next)

func _change_state(next: BossState) -> void:
	if next == current_state or next == null:
		return
	current_state.Exit()
	current_state = next
	current_state.Enter()
