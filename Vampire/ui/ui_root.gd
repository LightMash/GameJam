extends CanvasLayer

@onready var start_menu = $StartMenu
@onready var hud = $HUD
@onready var dice = $DiceScreen
@onready var pause = $PauseMenu
@onready var game_over = $GameOver
@onready var loading = $LoadingScreen

func _ready():
	hide_all()
	start_menu.visible = true

func hide_all():
	for child in get_children():
		child.visible = false

func show_start_menu():
	hide_all()
	start_menu.visible = true

func show_hud():
	hide_all()
	hud.visible = true

func show_dice():
	hide_all()
	dice.visible = true

func show_game_over():
	hide_all()
	game_over.visible = true

func show_loading():
	hide_all()
	loading.visible = true


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/story1.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
