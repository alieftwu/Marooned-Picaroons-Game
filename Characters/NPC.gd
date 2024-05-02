extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
<<<<<<< HEAD
=======
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")
>>>>>>> aliefs-branch

@export var npcText = ["I say words! and when you press space, I say more!", "like this!", "Very cool I know.", "Now lets fight!"]

signal showTextBox
signal hideTextBox
<<<<<<< HEAD
=======
signal newText(title)
>>>>>>> aliefs-branch

var closeEnough = false
var textDisplayed = false

func _ready():
	bubble.hide()
	pass

func _process(delta):
	if(closeEnough):
		bubble.show()
	else:
		bubble.hide()
	# check for interaction
	if Input.is_action_just_pressed("ui_accept") and closeEnough and !textDisplayed:
		textDisplayed = true
<<<<<<< HEAD
		print("output text: ", npcText, " goes here!")
		emit_signal("showTextBox")

func _on_area_2d_body_entered(body):
	if body != self and body != get_parent().get_node("TileMap"):
		print("display and await!")
		closeEnough = true


func _on_area_2d_body_exited(body):
	print("remove textbox")
	closeEnough = false
	textDisplayed = false
	emit_signal("hideTextBox")
=======
		print("output text here!")
		showTextBox.emit()

func _on_area_2d_body_entered(body):
	if body != self and body != get_tree().current_scene.get_node("TileMap"):
		print("display and await!\n", self.name)
		closeEnough = true
		newText.emit(self.name)


func _on_area_2d_body_exited(body):
	if(textDisplayed):
		emit_signal("hideTextBox")
		print("remove textbox")
		closeEnough = false
		textDisplayed = false
>>>>>>> aliefs-branch
