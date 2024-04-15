extends Node2D

@onready var BattleMap = get_parent()

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("testmove") == false:
		return
		
	BattleMap.movePerson(self)
			
