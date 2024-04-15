extends Node2D

@onready var BattleMap = get_parent()
var speed : int = 2

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("testmove") == false:
		return
		
	BattleMap.movePerson(self)
			
