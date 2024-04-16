extends Node2D

@onready var turn_queue = $TurnQueue
@onready var battle_map = $BattleMap

func _ready():
	turn_queue.initialize()
	battle_map.initialize()
	turn_queue.play_round()
