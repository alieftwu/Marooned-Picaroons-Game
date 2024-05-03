class_name SceneManager extends Node2D
var player : Player
var companion : Companion
var companion2 : Companion2
var last_scene_name: String
var scene_dir_path = "res://World/"
var combatScenePath = "res://Combat/Scenes/CombatScene.tscn"
var combatData : Array = []
signal sentCombatData

func change_scene(from, to_scene_name: String) -> void:
	last_scene_name = from.name
	companion = from.companion
	companion2 = from.companion2
	player = from.player
	var player_parent = player.get_parent()
	var companion_parent = companion.get_parent()
	var companion2_parent = companion2.get_parent()
	if player_parent != null:
		player.get_parent().remove_child(player)
		companion.get_parent().remove_child(companion)
		companion2.get_parent().remove_child(companion2)
	
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)

func combatSceneSwitch(originalScene, enemyList : Array, mapType : String) -> void:
	var PlayerList = [1,2,3,4,5]
	var EnemyList = ["a", "b", "c"]
	var callbackScene = str(originalScene)
	print(callbackScene)
	combatData = [PlayerList, EnemyList, mapType, callbackScene]
	originalScene.get_tree().call_deferred("change_scene_to_file", combatScenePath)

func switchBackScene(from, to_scene_name: String) -> void:
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)

func getCombatData():
	return combatData
