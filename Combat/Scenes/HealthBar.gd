extends ProgressBar

@onready var turn_queue = "res://Combat/Scenes/TurnQueue.tscn"

func UpdateHealthBar(character):
	max_value = character.stats.MaxHealth
	value = character.stats.Health
