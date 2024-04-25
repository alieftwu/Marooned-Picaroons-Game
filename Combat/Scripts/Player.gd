extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
var stats = load("res://Combat/Resources/playertest.tres")
var speed : int
var health : int
var basicAttackDamage : int
signal finishedTurn

func _ready():
	speed = stats.Speed
	health = stats.Health
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	print("pMove")
	await battlemap.movePerson(self)
	print("pBetweenMoveAtack")
	await battlemap.simpleAttack(self)
	print("pAttackAfter")
	emit_signal("finishedTurn")
