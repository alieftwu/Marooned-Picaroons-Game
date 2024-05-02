class_name SceneManager extends Node2D
var player : Player
<<<<<<< HEAD
=======
var companion : Companion
var companion2 : Companion2
>>>>>>> aliefs-branch
var last_scene_name: String
var scene_dir_path = "res://World/"


func change_scene(from, to_scene_name: String) -> void:
	last_scene_name = from.name
<<<<<<< HEAD
	player = from.player
	player.get_parent().remove_child(player)
=======
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
>>>>>>> aliefs-branch
	
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
	
