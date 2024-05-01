extends Panel

@onready var turn_queue = "res://Combat/Scenes/TurnQueue.tscn"
@onready var character_name = $CharacterName
@onready var health_bar = $HealthBar

func UpdateActivePanel(character):
	character_name.UpdateCharacterName(character)
	health_bar.UpdateHealthBar(character)
