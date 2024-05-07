class_name BaseScene extends Node

@onready var player : Player = $Player
@onready var companion : Companion = $Companion
@onready var companion2 : Companion2 = $Companion2
@onready var entrance_markers: Node2D = $EntranceMarkers
signal sceneTransition
signal removeNPC

func _ready():
	AudioPlayer.play_music_world()
	#handles player between scenes
	match name:
		"first_village":
			Global.firstVillageQuest = true
		"mountain_passage":
			Global.mountainPassage = true
		"second_village":
			if Global.firstVillageQuest:
				get_node("StaticBody2D/CollisionShape2D5").disabled = true
				get_node("NPC7")._on_second_village_remove_npc()
			if Global.mountainPassage:
				get_node("StaticBody2D/CollisionShape2D6").disabled = true
				get_node("NPC8")._on_second_village_remove_npc()
	if scene_manager.player:
		if is_instance_valid(scene_manager.player):
			var player_parent = scene_manager.player.get_parent()
			if player_parent != null:
				player_parent.remove_child(scene_manager.player)
				player = scene_manager.player
				add_child(player)
			sceneTransition.emit()
		print("I have reached the position player!")
		position_player()
	#handles 1st companion
	if scene_manager.companion:
		if is_instance_valid(scene_manager.companion):
			var companion_parent = scene_manager.companion.get_parent()
			if companion_parent != null:
				companion_parent.remove_child(scene_manager.companion)
				companion = scene_manager.companion
				add_child(companion)
			sceneTransition.emit()
			print("Companion 1 about to position")
			position_player()
	#handles 2nd companion
	if scene_manager.companion2:
		if is_instance_valid(scene_manager.companion2):
			var companion2_parent = scene_manager.companion2.get_parent()
			if companion2_parent != null:
				companion2_parent.remove_child(scene_manager.companion2)
				companion2 = scene_manager.companion2
				add_child(companion2)
			sceneTransition.emit()
			print("Companion 2 about to position")
			position_player()
			
func position_player() -> void:
	var last_scene = scene_manager.last_scene_name
	if last_scene.is_empty():
		last_scene = "any"
		
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == "any" or entrance.name == last_scene:
			player.global_position = entrance.global_position
			companion.global_position = entrance.global_position
			companion2.global_position = entrance.global_position


func _on_follow_node_set(node):
	$Camera2D.follow_node = node



func _on_halt_move():
	pass # Replace with function body.
