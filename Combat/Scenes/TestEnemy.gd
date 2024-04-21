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
	battlemap.moveEnemyPerson(self)
	await battlemap.characterMovementComplete
	battlemap.simpleEnemyAttack(self)
	#await battlemap.attackDone
	emit_signal("finishedTurn")
