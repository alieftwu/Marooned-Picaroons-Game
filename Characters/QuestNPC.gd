extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")

@export var questName = "quest name"
@export var preQuest = ["I say words! and ask you to do something!"]
@export var durQuest = ["How's that thing I told you to do going?"]
@export var postQuest = ["You came back! no way that's crazy!"]
@export var npcText = ["Seems like you're already busy. Come back when you're free to help."]
@export var questFinished = false
@export var questStarted = false

signal showTextBox
signal hideTextBox
signal newQText(title, QS, QF)
signal newText(title)

var closeEnough = false
var textDisplayed = false


func _ready():
	if Global.currentQuest == questName:
		questStarted = true
	for str in Global.completeQuests:
		if str == questName:
			questFinished = true
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
		if Global.currentQuest != null and Global.currentQuest != questName:
			newText.emit(name)
		elif questStarted == false and questFinished == false:
			Global.currentQuest = questName
			questStarted = true
			newQText.emit(name, false, false)
		elif questStarted == true and Global.currentQuestDone == false:
			newQText.emit(name, true, false)
		elif Global.currentQuest == questName and Global.currentQuestDone == true:
			if !questFinished:
				Global.questsDone += 1
				print(Global.questsDone)
				questFinished = true
				questStarted = false
				Global.currentQuest = null
				Global.currentQuestDone = false
				Global.completeQuests.append(questName)
				print(Global.completeQuests)
			newQText.emit(name, true, true)
		else:
			newQText.emit(name, questStarted, questFinished)
		emit_signal("showTextBox")

func _on_area_2d_body_entered(body):
	if body is Player:
		closeEnough = true

func _on_area_2d_body_exited(body):
	if(textDisplayed):
		emit_signal("hideTextBox")
		closeEnough = false
		textDisplayed = false
