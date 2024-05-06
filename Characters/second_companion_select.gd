extends Node2D


func _process(delta):
	match Global.second_companion:
		0:
			get_node("second_companion").play("Companion3")
			get_node("Desc").text = "-Risky Block\n-Circle Slash\n-Quick Strike\n-Takes 30% less damage from melee attacks."
		1:
			get_node("second_companion").play("Companion4")
			get_node("Desc").text = "-Bomb Throw\n-Circle Slash\n-Take Down\n-Increased Bomb damage by 40%.."
		2:
			get_node("second_companion").play("Companion5")
			get_node("Desc").text = "-Heavy Swing\n-Rapid Fire\n-Desparate Strike\n-Dodges 20% of attacks."
func _on_left_pressed():
	if Global.second_companion > 0:
		Global.second_companion -= 1


func _on_right_pressed():
	if Global.second_companion < 2:
		Global.second_companion += 1

func _on_select_pressed():
	get_tree().change_scene_to_file("res://World/world.tscn")
