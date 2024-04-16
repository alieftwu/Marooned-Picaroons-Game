extends Label

@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent().get_parent().get_node("NPC")
@onready var iterator = 0

# Called when the node enters the scene tree for the first time.

func _ready():
	visible_ratio = 0
	pass

func _process(delta):
	var tween = create_tween()
	visible_ratio = 0
	if textBox.visible == true:
		tween.tween_property(self, "visible_ratio", 2, 2.5)
	else:
		tween.tween_property(self, "visible_ratio", 0, 0.1)
		iterator = 0
	if textBox.visible == true and Input.is_action_just_pressed("ui_accept"):
		tween.tween_property(self, "visible_ratio", 0, 0.1)
		iterator += 1
		text = NPC.npcText[iterator]
		tween.tween_property(self, "visible_ratio", 2, 2.5)
