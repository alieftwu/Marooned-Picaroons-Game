extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
var stats = load("res://Combat/Resources/enemytest.tres")
var speed : int
var health : float
var basicAttackDamage : int
var passiveAbility : String = "none"

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
	print("e2Move")
	await battlemap.agressiveEnemyMove(self)
	print("e2betweenMoveAttack")
	await battlemap.simpleEnemyAttack(self)
	print("e2AttackAfter")
	emit_signal("finishedTurn")
