class_name Main_Menu
extends Control


@onready var start_button = $HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var start_level = preload("res://Main Menu/main_menu.tscn")


func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
	
func on_start_pressed() -> void:
	pass


func on_exit_pressed() -> void:
	get_tree().quit()
