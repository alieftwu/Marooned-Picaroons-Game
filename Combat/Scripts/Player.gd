extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var active_panel = $"../../ActivePanel/ActivePanel"
var stats = load("res://Combat/Resources/playertest.tres")

signal finishedTurn

func _ready():
	var _speed : int = stats.Speed

func play_turn():
	active_panel.UpdateActivePanel(self)
	active_panel.visible = true
	battlemap.movePerson(self)
	await battlemap.characterMovementComplete
	active_panel.visible = false
	emit_signal("finishedTurn")
