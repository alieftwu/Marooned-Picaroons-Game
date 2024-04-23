extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
var stats = load("res://Combat/Resources/enemytest.tres")
var speed : int
var health : int
var basicAttackDamage : int
signal finishedTurn

func _ready():
	speed = stats.Speed
	health = stats.Health
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	print("eMove")
	print("eMoveAfter")
	if randf() < .5:
		await battlemap.agressiveEnemyMove(self)
	else:
		await battlemap.moveEnemyPerson(self)
	print("eAttack")
	await battlemap.simpleEnemyAttack(self)
	print("pAttackAfter")
	emit_signal("finishedTurn")