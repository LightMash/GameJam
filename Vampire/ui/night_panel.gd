extends Control
@onready var day_label: Label = $NightPanel/MarginContainer/DayLabel
@onready var time_label: Label = $TimePanel/MarginContainer/TimeLabel


func _ready() -> void:
	NightCycleManager.time_tick.connect(on_time_tick)

func on_time_tick(day: int, hour: int, minute: int) -> void:
	day_label.text = "Day" + str(day)
	var display_hour = (hour + 19) % 24
	time_label.text= "%02d:%02d" % [display_hour,minute]
