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
	print("e1Move")
	await battlemap.moveEnemyPerson(self)
	print("e1betweenAttackMove")
	await battlemap.simpleEnemyAttack(self)
	print("e1AttackAfter")
	emit_signal("finishedTurn")
