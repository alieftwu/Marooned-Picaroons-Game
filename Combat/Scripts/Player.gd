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

signal finishedTurn

func _ready():
	speed = stats.Speed
	health = stats.Health
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	print("pMove")
	await battlemap.movePerson(self)
	print("pBetweenMoveAtack")
	#await battlemap.simpleAttack(self)
	await abilityControl.heavySwordSwing(self)
	await abilityControl.checkFlags(self)
	print("pAttackAfter")
	emit_signal("finishedTurn")
