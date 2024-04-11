class_name BaseScene extends Node

@onready var player : Player = $Player
@onready var entrance_markers: Node2D = $EntranceMarkers

func _ready():
	if scene_manager.player:
		if player:
			player.queue_free()
			
		player = scene_manager.player
		add_child(player)
	position_player()
	
func position_player() -> void:
	var last_scene = scene_manager.last_scene_name
	if last_scene.is_empty():
		last_scene = "any"
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == "any" or entrance.name == last_scene:
			player.global_position = entrance.global_position

func _on_follow_node_set(node):
	$Camera2D.follow_node = node
