extends Node2D


func _process(delta):
	match Game.PlayerSelect:
		0:
			get_node("PlayerSelect").play("Player0")
			get_node("Desc").text = "Special Abilities:\n-Can throw bomb and deal high damage of the enemy and any target near the enemy\n-Deals high damage when using ranged attacks  "
		1:
			get_node("PlayerSelect").play("Player1")
			get_node("Desc").text = "Special Abilities:\n-Can resist ranged attacks\n-Deals extra damage when using melee weapon"
func _on_left_pressed():
	if Game.PlayerSelect >= 0:
		Game.PlayerSelect -= 1


func _on_right_pressed():
	if Game.PlayerSelect < 2:
		Game.PlayerSelect += 1
