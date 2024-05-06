class_name Main_Menu
extends Control


@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var start_level = preload("res://World/world.tscn") as PackedScene


func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)


func on_exit_pressed() -> void:
	get_tree().quit()
	
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()
		


func _on_resume_pressed():
	resume()



func _on_quit_pressed():
	get_tree().quit()
	
func _process(delta):
	testEsc()
		
		 
		
		


	
