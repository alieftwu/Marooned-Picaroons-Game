extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var abilityControl = $"../../BattleMap/AbilityControl"
@onready var healthBar = $HealthBar
var stats = load("res://Combat/Resources/playertest.tres")
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
	print("Start Health: ", health)
	maxHealth = stats.MaxHealth
	armor = stats.Armor
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	updateHealthBar()
	print("pMove")
	await abilityControl.checkFlags(self)
	await battlemap.movePerson(self)
	print("pBetweenMoveAtack")
	#await battlemap.simpleAttack(self)
	await abilityControl.heavySwordSwing(self)
	print("pAttackAfter")
	if bonusMove == true:
		bonusMove = false
		await battlemap.movePerson(self)
		print("bonusmove")
	emit_signal("finishedTurn")

func updateHealthBar():
	var maxValue = maxHealth
	healthBar.value = (health / maxHealth) * 100
	print("new player health: ", (health / maxHealth) * 100)
