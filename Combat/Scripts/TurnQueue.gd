extends Node2D

class_name TurnQueue
@onready var battle_map = $"../BattleMap"
var num_children
var active_character
var new_index

signal endRound

func initialize():
	num_children = get_child_count()
	active_character = get_child(0)

func get_active_character():
	return active_character

func play_round():
	new_index = 0
	for child in get_children():
		#print("child ", active_character.get_index(), "'s turn has begun")
		child.play_turn()
		await child.finishedTurn
		#print("child ", active_character.get_index(), "'s turn has ended")
		new_index = active_character.get_index() + 1
		if new_index == num_children:
			emit_signal("endRound")
		active_character = get_child(new_index)
		
