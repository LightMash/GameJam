class_name NightCycleComponent
extends CanvasModulate



@export var initial_day: int = 1:
	set(id):
		initial_day = id
		NightCycleManager.initial_day = id
		NightCycleManager.set_initial_time()

@export var initial_hour: int = 19:
	set(ih):
		initial_hour = ih
		NightCycleManager.initial_hour = ih
		NightCycleManager.set_initial_time()

@export var initial_minute: int = 0:
	set(im):
		initial_minute = im
		NightCycleManager.initial_minute = im
		NightCycleManager.set_initial_time()


@export var night_gradient_texture: GradientTexture1D

func _ready() -> void:
	NightCycleManager.initial_day = initial_day
	NightCycleManager.initial_hour = initial_hour
	NightCycleManager.initial_minute = initial_minute
	NightCycleManager.set_initial_time()
	
	NightCycleManager.game_time.connect(on_game_time)
	
func on_game_time(progress: float) -> void:
	# progress goes 0.0 -> 1.0 each day (7pm -> 7am)
	color = night_gradient_texture.gradient.sample(progress)

	
	
