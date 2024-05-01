extends ProgressBar

@onready var turn_queue = "res://Combat/Scenes/TurnQueue.tscn"

func UpdateHealthBar(character):
	value = character.stats.Health
