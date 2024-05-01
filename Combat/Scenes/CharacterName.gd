extends RichTextLabel

@onready var turn_queue = "res://Combat/Scenes/TurnQueue.tscn"

func UpdateCharacterName(character):
	text = character.stats.Name
