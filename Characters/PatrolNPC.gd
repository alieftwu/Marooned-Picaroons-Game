extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")
@onready var animation_tree : AnimationTree = $AnimationTree

@export var direction = "down"
@export var npcText = ["Now lets fight!"]


signal showTextBox
signal hideTextBox
signal haltMove
signal newFText(title)

var closeEnough = false
var textDisplayed = false

func _ready():
	match direction:
		"down":
			animation_tree["parameters/Walk/blend_position"] = Vector2(0,1)
			around.rotation = Vector2(1,0).angle()
		"up":
			animation_tree["parameters/Walk/blend_position"] = Vector2(0,-1)
			around.rotation = Vector2(-1,0).angle()
		"left":
			animation_tree["parameters/Walk/blend_position"] = Vector2(-1,0)
			around.rotation = Vector2(0,1).angle()
		"right":
			animation_tree["parameters/Walk/blend_position"] = Vector2(1,0)
			around.rotation = Vector2(0,-1).angle()
	bubble.hide()
	pass

func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body != get_tree().current_scene.get_node("TileMap") and body != self:
		closeEnough = true
		haltMove.emit()
		newFText.emit(self.name)
		showTextBox.emit()

func _on_area_2d_body_exited(body):
	emit_signal("hideTextBox")
	closeEnough = false

