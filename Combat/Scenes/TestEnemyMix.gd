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
	print("e3Move")
	if randf() < .5:
		await battlemap.agressiveEnemyMove(self)
	else:
		await battlemap.moveEnemyPerson(self)
	print("e3BetweenMoveAttack")
	await battlemap.simpleEnemyAttack(self)
	print("e3AttackAfter")
	emit_signal("finishedTurn")