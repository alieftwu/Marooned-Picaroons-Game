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
	battlemap.moveEnemyPerson(self)
	print("eMoveAfter")
	await battlemap.characterMovementComplete
	print("eAttack")
	battlemap.simpleEnemyAttack(self)
	print("pAttackAfter")
	#await battlemap.attackDone
	emit_signal("finishedTurn")
