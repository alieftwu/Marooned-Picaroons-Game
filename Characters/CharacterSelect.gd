extends Node2D


func _process(delta):
	match Global.PlayerSelect:
		0:
			get_node("PlayerSelect").play("Player0")
			get_node("Desc").text = "-Can throw bomb and deal high damage of the enemy\n and any target near the enemy\n-Deals high damage when using ranged attacks  "
		1:
			get_node("PlayerSelect").play("Player1")
			get_node("Desc").text = "-Can resist ranged attacks\n-Deals extra damage when using melee weapon"
		2:
			get_node("PlayerSelect").play("Player2")
			get_node("Desc").text = "-Gets an extra turn when using melee\n-Deals extra damage when doing ranged attacks"
		3:
			get_node("PlayerSelect").play("Player3")
			get_node("Desc").text = "-Place Special Ability Here \n-Place Special Ability Here"
		4:
			get_node("PlayerSelect").play("Player4")
			get_node("Desc").text = "-Place Different Special Ability Here \n-Place Different Special Ability Here"
		5:
			get_node("PlayerSelect").play("Player5")
			get_node("Desc").text = "-Place Another Special Ability Here \n-Place Another Special Ability Here"
func _on_left_pressed():
	if Global.PlayerSelect >= 0:
		Global.PlayerSelect -= 1


func _on_right_pressed():
	if Global.PlayerSelect < 6:
		Global.PlayerSelect += 1

func _on_select_pressed():
	get_tree().change_scene_to_file("res://Characters/first_companion_select.tscn")
