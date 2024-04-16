extends Node2D

class_name TurnQueue
@onready var battle_map = $"../BattleMap"
var num_children
var active_character

func initialize():
	active_character = get_child(0)

func get_active_character():
	return active_character

func play_round():
	for child in get_children():
		print("child ", active_character.get_index(), "'s turn has begun")
		child.play_turn()
		await battle_map.finishedMoving
		print("child ", active_character.get_index(), "'s turn has ended")
		var new_index : int = (active_character.get_index() + 1)
		active_character = get_child(new_index)
