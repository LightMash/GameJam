class_name State extends Node
#stores the reference to the player that this state belongs to
static var player: Player

func _ready():
	pass 
	
func Enter() -> void: #what happens when the player enters this state?
	pass
	
func Exit() -> void: #what happens wjen the player exits this state?
	pass
	
func Process( _delta: float ) -> State: # what happens during the _process update in this state?
	return null
	
func Physics( _delta : float) -> State: #What happens during the _physics_process update in this state
	return null
	
func HandleInput( _event: InputEvent ) -> State: # What happens with input events in this state
	return null
