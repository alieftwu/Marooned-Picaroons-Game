extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")
@onready var animation_tree : AnimationTree = $AnimationTree

@export var direction = "down"
@export var npcText = ["I say words! and when you press space, I say more!"]

signal showTextBox
signal hideTextBox
signal newText(title)

var closeEnough = false
var textDisplayed = false

func _ready():
	bubble.hide()
	match direction:
		"down":
			animation_tree["parameters/Idle/blend_position"] = Vector2(0,1)
			around.rotation = Vector2(1,0).angle()
		"up":
			animation_tree["parameters/Idle/blend_position"] = Vector2(0,-1)
			around.rotation = Vector2(-1,0).angle()
		"left":
			animation_tree["parameters/Idle/blend_position"] = Vector2(-1,0)
			around.rotation = Vector2(0,1).angle()
		"right":
			animation_tree["parameters/Idle/blend_position"] = Vector2(1,0)
			around.rotation = Vector2(0,-1).angle()

func _process(delta):
	if(closeEnough):
		bubble.show()
	else:
		bubble.hide()
	# check for interaction
	if Input.is_action_just_pressed("ui_accept") and closeEnough and !textDisplayed:
		textDisplayed = true
		print("output text here!")
		showTextBox.emit()

func _on_area_2d_body_entered(body):
	if body != self and body != get_tree().current_scene.get_node("TileMap"):
		closeEnough = true
		newText.emit(self.name)


func _on_area_2d_body_exited(body):
	if(textDisplayed):
		emit_signal("hideTextBox")
		closeEnough = false
		textDisplayed = false
