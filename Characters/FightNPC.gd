extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")

@export var npcText = ["I say words! and when you press space, I say more!", "like this!", "Very cool I know.", "Now lets fight!"]

signal showTextBox
signal hideTextBox
signal haltMove
signal newText(title)

var closeEnough = false
var textDisplayed = false

func _ready():
	bubble.hide()
	pass

func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body != self and body != get_tree().current_scene.get_node("TileMap"):
		closeEnough = true
		newText.emit(self.name)
		showTextBox.emit()


func _on_area_2d_body_exited(body):
	emit_signal("hideTextBox")
	closeEnough = false

