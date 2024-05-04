extends Node

class_name PlayerManager
var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new()
	add_child(player)

func get_player_instance() -> Player:
	return player
func get_player() -> Player:
	return player
