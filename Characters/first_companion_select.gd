extends Node2D


func _process(delta):
	match Global.first_companion:
		0:
			get_node("first_companion").play("Companion0")
			get_node("Desc").text = "-Can throw bomb and deal high damage of the enemy\n and any target near the enemy\n-Deals high damage when using ranged attacks  "
		1:
			get_node("first_companion").play("Companion1")
			get_node("Desc").text = "-Can resist ranged attacks\n-Deals extra damage when using melee weapon"
		2:
			get_node("first_companion").play("Companion2")
			get_node("Desc").text = "-Gets an extra turn when using melee\n-Deals extra damage when doing ranged attacks"
func _on_left_pressed():
	if Global.first_companion >= 0:
		Global.first_companion -= 1


func _on_right_pressed():
	if Global.first_companion < 3:
		Global.first_companion += 1

func _on_select_pressed():
	get_tree().change_scene_to_file("res://Characters/second_companion_select.tscn")
