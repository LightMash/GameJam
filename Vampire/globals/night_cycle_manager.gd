extends Node

# Real-time duration of one full "day" (7pm -> 7am)
const DAY_DURATION_SECONDS: float = 2.0 * 60.0  # 5 minutes

# In-game displayed clock window
const START_HOUR: int = 19          # 19 = 7 PM
const HOURS_PER_CYCLE: int = 12     # 7 PM -> 7 AM
const GAME_MINUTES_PER_DAY: int = HOURS_PER_CYCLE * 60  # 720

# How fast time passes (1.0 = exactly 5 minutes per day)
@export var game_speed: float = 1.0

# Initial time (must be inside the 7pm->7am window)
var initial_day: int = 1
var initial_hour: int = 19
var initial_minute: int = 0

# Internal time tracking (in "game minutes" since day 1 start)
var total_game_minutes: float = 0.0
var current_minute: int = -1
var current_day: int = -1

# Signals
signal game_time(progress_0_to_1: float)       # 0..1 over the current day window (7pm->7am)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)

func _ready() -> void:
	set_initial_time()

func _process(delta: float) -> void:
	# Convert real seconds -> game minutes
	var game_minutes_per_second := GAME_MINUTES_PER_DAY / DAY_DURATION_SECONDS
	total_game_minutes += delta * game_speed * game_minutes_per_second
	
	recalculate_time()

func set_initial_time() -> void:
	# Convert initial (clock) time into minutes since START_HOUR
	var minutes_since_start := ((initial_hour - START_HOUR + 24) % 24) * 60 + initial_minute
	
	# Clamp so we don't start outside the 7pm->7am window
	minutes_since_start = clamp(minutes_since_start, 0, GAME_MINUTES_PER_DAY - 1)
	
	# Day 1 corresponds to base 0 minutes
	total_game_minutes = float((initial_day - 1) * GAME_MINUTES_PER_DAY + minutes_since_start)

	# Force an update immediately
	current_minute = -1
	current_day = -1
	recalculate_time()

func recalculate_time() -> void:
	var total_minutes_int := int(floor(total_game_minutes))
	var day := int(total_minutes_int / GAME_MINUTES_PER_DAY) + 1
	
	var minutes_of_day := total_minutes_int % GAME_MINUTES_PER_DAY
	var hour_in_window := int(minutes_of_day / 60)
	var minute := int(minutes_of_day % 60)
	
	# Convert window-hour to real clock hour (19..23 then 0..6)
	var hour := (START_HOUR + hour_in_window) % 24

	# Progress 0..1 through the current "day" (7pm->7am)
	var progress := float(minutes_of_day) / float(GAME_MINUTES_PER_DAY - 1)
	game_time.emit(progress)

	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day, hour, minute)

	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
