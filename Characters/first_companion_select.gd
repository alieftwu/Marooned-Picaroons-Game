extends Node2D


func _process(delta):
	match Global.first_companion:
		0:
			get_node("first_companion").play("Companion0")
			get_node("Desc").text = "-Reckless Frenzy\n-Dagger Toss\n-Cannon Shot\n-25% Increased Melee damage."
		1:
			get_node("first_companion").play("Companion1")
			get_node("Desc").text = "-Heavy Swing\n-Risky Block\n-Bomb Throw\n-Take 30% less Melee damage."
		2:
			get_node("first_companion").play("Companion2")
			get_node("Desc").text = "-Quick Strike\n-Rapid Fire\n-Take Down\n-50% dodge chance, 20% less attack."
func _on_left_pressed():
	if Global.first_companion > 0:
		Global.first_companion -= 1


func _on_right_pressed():
	if Global.first_companion < 2:
		Global.first_companion += 1

func _on_select_pressed():
	get_tree().change_scene_to_file("res://Characters/second_companion_select.tscn")
