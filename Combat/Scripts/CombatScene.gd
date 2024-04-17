extends Node2D

@onready var turn_queue = $TurnQueue
@onready var battle_map = $BattleMap

func _ready():
	turn_queue.initialize()
	battle_map.initialize()
	start_game()

func start_game():
	while 1:
		turn_queue.play_round()
		await turn_queue.endRound
