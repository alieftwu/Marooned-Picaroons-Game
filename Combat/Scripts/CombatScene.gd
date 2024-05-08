extends Node2D

@onready var turn_queue = $TurnQueue
@onready var battle_map = $BattleMap
@onready var highlight_map = $HighlightMap
@onready var combatInformation
# var current_scene_path = get_tree().get_current_scene().get_path()
func _ready():
	combatInformation = await scene_manager.getCombatData()
	#print("twat: ", combatInformation[3])
	turn_queue.initialize()
	battle_map.initialize()
	start_game()

func start_game():
	while 1:
		await turn_queue.play_round()
