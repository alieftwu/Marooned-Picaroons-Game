extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var healthBar = $HealthBar
var stats = load("res://Combat/Resources/enemytest.tres")
var speed : int
var health : float
var maxHealth : float
var armor : int
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
	maxHealth = stats.MaxHealth
	armor = stats.Armor
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	updateHealthBar()
	print("e3Move")
	if randf() < .75:
		await battlemap.agressiveEnemyMove(self)
	else:
		await battlemap.moveEnemyPerson(self)
	print("e3BetweenMoveAttack")
	await battlemap.simpleEnemyAttack(self)
	print("e3AttackAfter")
	emit_signal("finishedTurn")

func updateHealthBar():
	var maxValue = maxHealth
	healthBar.value = (health / maxHealth) * 100
	print("new enemy health: ", (health / maxHealth) * 100)
