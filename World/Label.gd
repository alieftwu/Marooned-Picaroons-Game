extends Label
@export var combat_scene: String #name of scene to change to
@onready var textBox = get_parent() 
@onready var NPC = get_parent().get_parent().get_parent() 
@onready var iterator = -1
@onready var textList = [""]
@onready var doFight = false

# Called when the node enters the scene tree for the first time.
signal hideBoxLabel
signal hideHideable

func _ready():
	if(Global.currentFightNPC == NPC.name and Global.currentFightWon):
		NPC.hasWon = true
		Global.currentFightNPC = null
		Global.currentFightWon = false
	text = ""
	textList[0] = text
	pass

func _process(delta):
	if textBox.visible and Input.is_action_just_pressed("ui_accept") and iterator < textList.size()-1:
		iterator += 1
		text = textList[iterator]
	elif textBox.visible and Input.is_action_just_pressed("ui_accept") and iterator == textList.size()-1:
		emit_signal("hideBoxLabel")
		emit_signal("hideHideable")
		iterator = -1
		if doFight:
			Global.currentFightNPC = NPC.name
			scene_manager.combatSceneSwitch(get_owner(), combat_scene)


func _on_new_text(title):
	textList = NPC.npcText
	text = textList[0]


func _on_new_q_text(title, QS, QF):
	if QS and !QF:
		textList = NPC.durQuest
	else:
		textList = NPC.preQuest
	if QF:
		textList = NPC.postQuest
	text = textList[0]


func _on_npc_halt_move():
	iterator = 0


func _on_new_f_text(title):
	# connected_scene = scene
	textList = NPC.npcText
	text = textList[0]
	doFight = true

func _on_npc_new_i_text(title, IC):
	if IC:
		textList = NPC.postItem
	else:
		textList = NPC.preItem
	text = textList[0]
