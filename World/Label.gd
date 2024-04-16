extends Label

@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent().get_parent().get_node("NPC")
@onready var iterator = 0

# Called when the node enters the scene tree for the first time.
signal hideBoxLabel

func _ready():
	text = NPC.npcText[0]
	visible_ratio = 0
	pass

func _process(delta):
	var tween = create_tween()
	visible_ratio = 0
	if textBox.visible == true:
		tween.tween_property(self, "visible_ratio", 2, 5)
	else:
		tween.tween_property(self, "visible_ratio", -1, 0.1)
		visible_ratio = 0
		iterator = 0
		text = NPC.npcText[0]
	if textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator < NPC.npcText.size()-1:
		tween.tween_property(self, "visible_ratio", -1, 0.1)
		visible_ratio = 0
		iterator += 1
		text = NPC.npcText[iterator]
		tween.tween_property(self, "visible_ratio", 2, 5)
	elif textBox.visible == true and Input.is_action_just_pressed("ui_accept") and iterator == NPC.npcText.size():
		emit_signal("hideBoxLabel")
