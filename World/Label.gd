extends Label
@export var connected_scene: String #name of scene to change to
@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent().get_parent()
@onready var iterator = 0

# Called when the node enters the scene tree for the first time.
signal hideBoxLabel

func _ready():
	text = ""
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
	if textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator < NPC.npcText.size()-1:
		tween.tween_property(self, "visible_ratio", -2, 0.1)
		visible_ratio = 0
		iterator += 1
		text = NPC.npcText[iterator]
		tween.tween_property(self, "visible_ratio", 2, 5)
	elif textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator == NPC.npcText.size()-1:
		emit_signal("hideBoxLabel")
		NPC = NPC.get_parent()
		print("swap to scene for fighting")
		# scene_manager.change_scene(get_owner(), connected_scene)


func _on_fighty_new_text():
	NPC = NPC.get_node("fighty")
	text = NPC.npcText[0]


func _on_talky_new_text():
	NPC = NPC.get_node("talky")
	text = NPC.npcText[0]


func _on_child_new_text():
	NPC = NPC.get_node("child")
	text = NPC.npcText[0]


func _on_parent_new_text():
	NPC = NPC.get_node("parent")
	text = NPC.npcText[0] 
