extends Node

const MINUTES_PER_DAY: int = 5 * 60
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY

var game_speed: float = 5.0

var inital_day: int = 1
var initial_hour: int =12
var initial_minute: int = 30

var time: float = 0.0
var current_minute: int = -1
var current_day: int = 0

#Signals

signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)

func set_initial_time() -> void:
	var intial_total_minutes = inital_day * MINUTES_PER_DAY
