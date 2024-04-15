extends Node2D

class_name TurnQueue

var active_character

func initialize():
	active_character = get_child(0) #this will work if I can find a way to initialize the children before this so that it can be done randomly

#func play_turn():
	#await active_character.play_turn()
	#var new_index : int = (active_character.get_index() + 1) % get_child_count()
	#active_character = get_child(new_index)
