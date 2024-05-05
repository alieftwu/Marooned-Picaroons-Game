extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")

@export var questName = "quest name"
@export var preQuest = ["I say words! and ask you to do something!"]
@export var durQuest = ["How's that thing I told you to do going?"]
@export var postQuest = ["You came back! no way that's crazy!"]
@export var questFinished = false
@export var questStarted = false

signal showTextBox
signal hideTextBox
signal newQText(title, QS, QF)

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
		if !questStarted and !Global.currentQuestDone:
			questStarted = true
			Global.currentQuest = questName
		if Global.currentQuestDone:
			if Global.currentQuest == questName:
				Global.questsDone += 1
			questFinished = true
			newQText.emit(name, questStarted, questFinished)
			Global.currentQuest = "none"
		emit_signal("showTextBox")

func _on_area_2d_body_entered(body):
	if body is Player:
		print("display and await!")
		closeEnough = true
		newQText.emit(name, questStarted, questFinished)


func _on_area_2d_body_exited(body):
	if(textDisplayed):
		emit_signal("hideTextBox")
		print("remove textbox")
		closeEnough = false
		textDisplayed = false
