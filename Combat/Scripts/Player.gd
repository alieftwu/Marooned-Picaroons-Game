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
	battlemap.movePerson(self)
	print("pMoveAfter")
	await battlemap.characterMovementComplete
	print("pAttack")
	battlemap.simpleAttack(self)
	await battlemap.attackDone
	print("pAttackAfter")
	emit_signal("finishedTurn")
