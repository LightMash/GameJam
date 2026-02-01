class_name MonsterStateMachine
extends Node

var states: Array[MonsterState] = []
var current_state: MonsterState
var prev_state: MonsterState

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	var m := get_parent() as CharacterBody2D
	if m != null:
		Initialize(m)

func Initialize(monster_ref: CharacterBody2D) -> void:
	states.clear()
	for c in get_children():
		if c is MonsterState:
			c.monster = monster_ref
			states.append(c)

	if states.size() > 0:
		ChangeState(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta: float) -> void:
	if current_state:
		ChangeState(current_state.Process(delta))

func _physics_process(delta: float) -> void:
	if current_state:
		ChangeState(current_state.Physics(delta))

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		ChangeState(current_state.HandleInput(event))

func ChangeState(new_state: MonsterState) -> void:
	if new_state == null or new_state == current_state:
		return
	if current_state:
		current_state.Exit()
	prev_state = current_state
	current_state = new_state
	current_state.Enter()
