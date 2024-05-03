extends Label
@export var connected_scene: String #name of scene to change to
@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent() 
@onready var iterator = -1
@onready var textList = [""]

# Called when the node enters the scene tree for the first time.
signal hideBoxLabel

func _ready():
	text = ""
	textList[0] = text
	pass

func _process(delta):
	if textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator < textList.size()-1:
		iterator += 1
		text = textList[iterator]
	elif textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator == textList.size()-1:
		emit_signal("hideBoxLabel")
		print("swap to scene for fighting")
		iterator = -1
		# scene_manager.change_scene(get_owner(), connected_scene)


func _on_new_text(title):
	print("new text selected!")
	NPC = NPC.get_parent().get_node(NodePath(title))
	textList = NPC.npcText
	text = textList[0]


func _on_new_q_text(title, QS, QF):
	NPC = NPC.get_parent().get_node(NodePath(title))
	if QS and !QF:
		textList = NPC.durQuest
	else:
		textList = NPC.preQuest
	if QF:
		textList = NPC.postQuest
	text = textList[0]


func _on_scene_transition():
	print("here I am!")
