class_name SceneManager extends Node2D
var player : Player
var companion : Companion
var last_scene_name: String
var scene_dir_path = "res://World/"


func change_scene(from, to_scene_name: String) -> void:
	last_scene_name = from.name
	companion = from.companion
	player = from.player
	var player_parent = player.get_parent()
	var companion_parent = companion.get_parent()
	if player_parent != null:
		player.get_parent().remove_child(player)
		companion.get_parent().remove_child(companion)
	
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
	
