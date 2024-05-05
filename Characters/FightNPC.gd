extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var textBox = get_node("HUD/TextureRect")
@onready var textBoxText = get_node("HUD/TextureRect/Label")
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animations : AnimationPlayer = $PlayerAnimation

@export var direction = "down"
@export var npcText = ["Now lets fight!"]
@export var hasWon = false
@export var killable = false


signal showTextBox
signal hideTextBox
signal haltMove
signal newFText(title)

var closeEnough = false
var textDisplayed = false

func _ready():
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
	bubble.hide()
	pass

func _process(delta):
	if hasWon:
		if killable:
			hide()
			get_node("CollisionShape2D").disabled = true
		around.hide()
		around.get_node("CollisionPolygon2D").disabled = true
	else:
		show()
		get_node("CollisionShape2D").disabled = false
		around.show()
		around.get_node("CollisionPolygon2D").disabled = false
	match direction:
		"down":
			around.rotation = Vector2(1,0).angle()
		"up":
			around.rotation = Vector2(-1,0).angle()
		"left":
			around.rotation = Vector2(0,1).angle()
		"right":
			around.rotation = Vector2(0,-1).angle()
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

