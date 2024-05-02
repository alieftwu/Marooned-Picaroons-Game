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
var abilityList : Array = ["cannonShot", "pistolShot", "engagingBlock"] # buttons 2-4 abilities. can switch out 
# look at abilityControl checkMoveSlot

var frenzyBuff : bool = false # used to determine when 2 turns are up
var frenzyBuffCount : int = 0
var isStunned : bool = false
var isStunnedCount : int = 0
var bonusMove = false
var isBlocking = false
var didBlock = false
signal finishedTurn

var canPress : bool = false
var special1CoolDown : int = 0 # can only attack when = 0, goes down at end of turn by 1
var special2CoolDown : int = 0 # can only attack when = 0, goes down at end of turn by 1
var special3CoolDown : int = 0 # can only attack when = 0, goes down at end of turn by 1

func _ready():
	speed = stats.Speed
	health = stats.Health
	print("Start Health: ", health)
	maxHealth = stats.MaxHealth
	armor = stats.Armor
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	updateHealthBar()
	var skipTurn = await abilityControl.checkStun(self)
	if skipTurn == false:
		await abilityControl.checkFlags(self)
		await battlemap.setAttackIconsDull() # make buttons dull
		print("pMove")
		await battlemap.movePerson(self)
		print("pBetweenMoveAtack")
		await battlemap.checkCooldownIcons(self) # updates buttons with cooldown icons
		canPress = true
		await battlemap.abilityFinished
		print("pAttackAfter")
		if bonusMove == true:
			bonusMove = false
			await battlemap.movePerson(self)
			print("bonusmove")
	else:
		print("player is stunned!")
	updateCooldowns()
	emit_signal("finishedTurn")

func updateHealthBar():
	var maxValue = maxHealth
	healthBar.value = (health / maxHealth) * 100
	#print("new player health: ", (health / maxHealth) * 100)
	
func updateCooldowns():
	if special1CoolDown >= 1:
		special1CoolDown -= 1
	if special2CoolDown >= 1:
		special2CoolDown -= 1
	if special3CoolDown >= 1:
		special3CoolDown -= 1
	return
