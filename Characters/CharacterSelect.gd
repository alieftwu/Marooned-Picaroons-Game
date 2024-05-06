extends Node2D


func _process(delta):
	match Global.PlayerSelect:
		0:
			get_node("PlayerSelect").play("Player0")
			get_node("Desc").text = "-Bomb Throw\n-Dagger Toss\n-Quick Strike\n-Dodges 20% of attacks."
		1:
			get_node("PlayerSelect").play("Player1")
			get_node("Desc").text = "-Heavy Swing\n-Circle Slash\n-Reckless Frenzy\n-Deals 25% extra melee damage."
		2:
			get_node("PlayerSelect").play("Player2")
			get_node("Desc").text = "-Pistol Shot\n-Rapid Fire\n-Pirate Blessing\n-Deals 30% extra ranged damage."
		3:
			get_node("PlayerSelect").play("Player3")
			get_node("Desc").text = "-Cannon Shot\n-Risky Block\n-Desparate Strike \n-Takes 30% less damage from melee attacks."
		4:
			get_node("PlayerSelect").play("Player4")
			get_node("Desc").text = "-Take Down\n-Pistol Shot\n-Heavy Swing\n-Dodges 20% of attacks."
		5:
			get_node("PlayerSelect").play("Player5")
			get_node("Desc").text = "-PirateBlessing\n-Dagger Toss\n-Risky Block \n-Takes 35% less damage from ranged attacks."
func _on_left_pressed():
	if Global.PlayerSelect >= 0:
		Global.PlayerSelect -= 1

func _on_right_pressed():
	if Global.PlayerSelect < 6:
		Global.PlayerSelect += 1

func _on_select_pressed():
	get_tree().change_scene_to_file("res://Characters/first_companion_select.tscn")
