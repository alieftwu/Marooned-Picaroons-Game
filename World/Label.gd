extends Label
@export var connected_scene: String #name of scene to change to
@onready var textBox = get_parent() 
@onready var NPC = get_tree().current_scene
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
		NPC = NPC.get_tree().current_scene
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
		print("swap to scene for fighting")
		# scene_manager.change_scene(get_owner(), connected_scene)


func _on_new_text(title):
	NPC = NPC.get_node(NodePath(title))
	textList = NPC.npcText
	text = textList[0]


func _on_new_q_text(title, QS, QF):
	NPC = NPC.get_node(NodePath(title))
	if QS:
		textList = NPC.durQuest
	else:
		textList = NPC.preQuest
	if QF:
		textList = NPC.postQuest
	text = textList[0]


func _on_scene_transition():
	NPC = get_tree().current_scene
	print("here I am!")
