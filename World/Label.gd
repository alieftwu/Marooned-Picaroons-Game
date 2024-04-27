extends Label
@export var connected_scene: String #name of scene to change to
@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent().get_parent()
@onready var iterator = 0
@onready var textList = [""]

# Called when the node enters the scene tree for the first time.
signal hideBoxLabel

func _ready():
	text = ""
	textList[0] = text
	visible_ratio = 0
	pass

func _process(delta):
	var tween = create_tween()
	visible_ratio = 0
	if textBox.visible == true:
		tween.tween_property(self, "visible_ratio", 2, 5)
	else:
		tween.tween_property(self, "visible_ratio", -2, 0.1)
		visible_ratio = 0
		iterator = 0
	if textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator < textList.size()-1:
		tween.tween_property(self, "visible_ratio", -2, 0.1)
		visible_ratio = 0
		iterator += 1
		text = textList[iterator]
		tween.tween_property(self, "visible_ratio", 2, 5)
	elif textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator == textList.size()-1:
		emit_signal("hideBoxLabel")
		NPC = NPC.get_parent()
		print("swap to scene for fighting")
		# scene_manager.change_scene(get_owner(), connected_scene)


func _on_new_text(title):
	NPC = NPC.get_node(NodePath(title))
	text = NPC.npcText[0]  
	textList = NPC.npcText


func _on_new_q_text(title, QS, QF):
	NPC = NPC.get_node(NodePath(title))
	if QS:
		text = NPC.durQuest[0]
		textList = NPC.durQuest
	else:
		text = NPC.preQuest[0]
		textList = NPC.preQuest
	if QF:
		text = NPC.postQuest[0]
		textList = NPC.postQuest
	






