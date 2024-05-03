extends Node2D

class_name TurnQueue
@onready var battle_map = $"../BattleMap"
#Variable typed in INSPECTOR to go back to last scene
@export var connected_scene: String
var num_children
var active_character
var new_index
var gameResult
var activeUnits
signal endRound

func initialize():
	num_children = get_child_count()
	active_character = get_child(0)

func get_active_character():
	return active_character

func play_round():
	new_index = 0
	activeUnits = get_children()
	for child in activeUnits:
		#print("child ", active_character.get_index(), "'s turn has begun")
		if child in battle_map.Units:
			active_character = child
			print("Turn of " + str(child))
			await child.play_turn()
		checkDeaths()
		gameResult = checkGameOver()
		if gameResult == 1:
			print("You lost")
			#scene_manager.change_scene(get_owner(), connected_scene)
			#takes player back to original scene
			scene_manager.switchBackScene(get_owner(), connected_scene)
			break
		if gameResult == 2:
			print("You Won!")
			#scene_manager.change_scene(get_owner(), connected_scene)
			#takes player back to original scene
			scene_manager.switchBackScene(get_owner(), connected_scene)
			break
		#print("child ", active_character.get_index(), "'s turn has ended")
		new_index = active_character.get_index() + 1
		battle_map.gatherUnitInfo() # good to make sure Unit tracker up to date
		num_children = get_child_count()
		print("numchildren: " + str(num_children) + " index: " + str(new_index))
		if new_index >= num_children:
			break
	
	emit_signal("endRound")
	print("Round End")
	return
		
func checkDeaths(): # i just make them invisible for now, we will need other way of handling 
	for unit in battle_map.Units:
		if unit.health <= 0:
			unit.remove_from_group("Units")
			unit.remove_from_group("PlayerUnits")
			unit.remove_from_group("EnemyUnits")
			activeUnits.erase(unit)
			remove_child(unit)
			unit.queue_free()
			battle_map.gatherUnitInfo() # since unit is deleted, groups should update to show that
	return
	
func checkGameOver():
	if battle_map.friendlyUnits.is_empty():
		return 1 # 1 results in a loss
	if battle_map.enemyUnits.is_empty():
		return 2 # 2 results in a win
	else:
		return 0 # 0 nothing happens

func addUnits(playerUnits, enemyUnits): # add units to scene, spawn them in, not tested if works
	var playerList = []
	for unit in playerUnits:
		var newUnit = unit.instance()
		add_child(newUnit)
		playerList.append(newUnit)
	var enemyList = []
	for unit in enemyUnits:
		var newEnemyUnit = unit.instance()
		add_child(newEnemyUnit)
		enemyList.append(newEnemyUnit)
		
	battle_map.spawnUnits(playerList, enemyList)
	return
