extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var abilityControl = $"../../BattleMap/AbilityControl"
var stats = load("res://Combat/Resources/playertest.tres")
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
