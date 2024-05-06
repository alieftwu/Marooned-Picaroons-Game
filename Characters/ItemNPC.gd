extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")

@export var connectedQuest = "quest"
@export var npcText = ["Howdy! I give items!"]
@export var preItem = ["I say words! and ask you to do something!"]
@export var postItem = ["How's that thing I told you to do going?"]
@export var itemCollected = false

signal showTextBox
signal hideTextBox
signal newIText(title, IC)
signal newText(title)

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
		emit_signal("showTextBox")
		if !itemCollected and Global.currentQuest == connectedQuest:
			itemCollected = true
			Global.currentQuestDone = true

func _on_area_2d_body_entered(body):
	if body != self and body != get_tree().current_scene.get_node("TileMap"):
		print("display and await!")
		closeEnough = true
		if Global.currentQuest == connectedQuest:
			newIText.emit(name, itemCollected)
		else:
			newText.emit(name)


func _on_area_2d_body_exited(body):
	if(textDisplayed):
		emit_signal("hideTextBox")
		print("remove textbox")
		closeEnough = false
		textDisplayed = false
