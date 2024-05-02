extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
var stats = load("res://Combat/Resources/enemytest.tres")
var speed : int
var health : float
var basicAttackDamage : int
var passiveAbility : String = "Brawler"

var frenzyBuff : bool = false # used to determine when 2 turns are up
var frenzyBuffCount : int = 0
var isStunned : bool = false
var isStunnedCount : int = 0
var bonusMove = false
var isBlocking = false
var didBlock = false
signal finishedTurn

func _ready():
	speed = stats.Speed
	health = stats.Health
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	print("e3Move")
	if randf() < .75:
		await battlemap.agressiveEnemyMove(self)
	else:
		await battlemap.moveEnemyPerson(self)
	print("e3BetweenMoveAttack")
	await battlemap.simpleEnemyAttack(self)
	print("e3AttackAfter")
	emit_signal("finishedTurn")
