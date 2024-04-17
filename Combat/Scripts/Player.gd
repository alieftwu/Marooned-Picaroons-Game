extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
var stats = load("res://Combat/Resources/playertest.tres")

func _ready():
	var _speed : int = stats.Speed

func play_turn():
	battlemap.movePerson(self)
