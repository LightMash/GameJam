extends CanvasLayer

@onready var music_slider: HSlider = $Settings/SettingsBackground/SettingsPanel/VBoxContainer/MusicVBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Settings/SettingsBackground/SettingsPanel/VBoxContainer/SFXVBoxContainer/SFXSLider

# Audio bus indices
const MUSIC_BUS = 1
const SFX_BUS = 2

func _ready() -> void:
	# Set up slider ranges (0-100 for percentage)
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.step = 1
	
	# Load saved volumes or set defaults
	var music_volume = 100  # Default to 100%
	var sfx_volume = 100    # Default to 100%
	
	# Convert percentage to dB and set initial volumes
	music_slider.value = music_volume
	sfx_slider.value = sfx_volume
	_set_volume(MUSIC_BUS, music_volume)
	_set_volume(SFX_BUS, sfx_volume)
	
	# Connect slider signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _on_music_slider_changed(value: float) -> void:
	_set_volume(MUSIC_BUS, value)

func _on_sfx_slider_changed(value: float) -> void:
	_set_volume(SFX_BUS, value)

func _set_volume(bus_index: int, volume_percent: float) -> void:
	# Convert percentage (0-100) to decibels
	# 0% = -80dB (effectively muted)
	# 100% = 0dB (full volume)
	if volume_percent <= 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		# Linear to dB conversion: dB = 20 * log10(linear)
		# We map 0-100% to -80dB to 0dB using a logarithmic scale
		var db = linear_to_db(volume_percent / 100.0)
		AudioServer.set_bus_volume_db(bus_index, db)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
