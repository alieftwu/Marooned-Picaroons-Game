extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")
@onready var animation_tree : AnimationTree = $AnimationTree

@export var npcText = ["I say words! and when you press space, I say more!", "like this!", "Very cool I know.", "Now lets fight!"]
@export var fightScene = NodePath()
signal showTextBox
signal hideTextBox
signal haltMove
signal newFText(title, scene)

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
		haltMove.emit()
		newFText.emit(self.name, fightScene)
		showTextBox.emit()
		

func _on_area_2d_body_exited(body):
	emit_signal("hideTextBox")
	closeEnough = false

