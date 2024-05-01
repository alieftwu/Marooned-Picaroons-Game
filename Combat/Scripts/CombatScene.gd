extends Node2D

@onready var turn_queue = $TurnQueue
@onready var battle_map = $BattleMap
@onready var active_panel = $ActivePanel/ActivePanel
@onready var target_panel = $TargetPanel

func _ready():
	turn_queue.initialize()
	battle_map.initialize()
	active_panel.visible = false
	target_panel.visible = false
	start_game()

func start_game():
	while 1:
		turn_queue.play_round()
		await turn_queue.endRound
