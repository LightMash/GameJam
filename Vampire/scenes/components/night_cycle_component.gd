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

# Music settings
@export var day_music_threshold: float = 0.5  # When progress > 0.5, play day music (approaching 7am)
@export var crossfade_duration: float = 2.0   # Smooth transition between tracks

@onready var night_music: AudioStreamPlayer = $NightMusic
@onready var day_music: AudioStreamPlayer = $DayMusic

var current_phase: String = "night"  # "night" or "day"

func _ready() -> void:
	NightCycleManager.initial_day = initial_day
	NightCycleManager.initial_hour = initial_hour
	NightCycleManager.initial_minute = initial_minute
	NightCycleManager.set_initial_time()
	
	NightCycleManager.game_time.connect(on_game_time)
	NightCycleManager.time_tick_day.connect(on_new_day)
	
	# Start with night music (game starts at 7pm = night)
	if night_music:
		night_music.play()
		current_phase = "night"
	
func on_game_time(progress: float) -> void:
	# progress goes 0.0 -> 1.0 each day (7pm -> 7am)
	color = night_gradient_texture.gradient.sample(progress)
	
	# Switch music based on time of day
	# Progress 0.0 = 7pm (night), 0.5 = 1am (still night), 1.0 = 7am (day)
	if progress >= day_music_threshold and current_phase == "night":
		# Transition to day music (approaching morning)
		transition_to_day()
	elif progress < day_music_threshold and current_phase == "day":
		# Transition to night music (back to evening)
		transition_to_night()

func on_new_day(day: int) -> void:
	# Reset to night music at start of each day (7pm)
	if current_phase != "night":
		transition_to_night()

func transition_to_day() -> void:
	current_phase = "day"
	if day_music and night_music:
		# Crossfade from night to day
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(night_music, "volume_db", -80, crossfade_duration)
		tween.tween_property(day_music, "volume_db", 0, crossfade_duration)
		
		# Start day music if not playing
		if not day_music.playing:
			day_music.volume_db = -80
			day_music.play()
		
		# Stop night music after fade
		tween.chain().tween_callback(night_music.stop)

func transition_to_night() -> void:
	current_phase = "night"
	if day_music and night_music:
		# Crossfade from day to night
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(day_music, "volume_db", -80, crossfade_duration)
		tween.tween_property(night_music, "volume_db", 0, crossfade_duration)
		
		# Start night music if not playing
		if not night_music.playing:
			night_music.volume_db = -80
			night_music.play()
		
		# Stop day music after fade
		tween.chain().tween_callback(day_music.stop)

	
	
