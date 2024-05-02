extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var healthBar = $HealthBar
@onready var abilityControl = $"../../BattleMap/AbilityControl"
var stats = load("res://Combat/Resources/enemytest.tres")
var speed : int
var health : float
var maxHealth : float
var armor : int
var basicAttackDamage : int
var passiveAbility : String = "none"
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
	maxHealth = stats.MaxHealth
	armor = stats.Armor
	basicAttackDamage = stats.BasicAttackDamage

func play_turn():
	updateHealthBar()
	var skipTurn = await abilityControl.checkStun(self)
	if skipTurn == false:
		abilityControl.checkFlags(self)
		battlemap.setAttackIconsDull() # make buttons dull
		print("e1Move")
		await battlemap.moveEnemyPerson(self)
		print("e1betweenAttackMove")
		battlemap.checkCooldownIcons(self) # updates buttons with cooldown icons
		await battlemap.enemyRandomAbility(self)
		print("e1AttackAfter")
	updateCooldowns()
	emit_signal("finishedTurn")

func updateHealthBar():
	var maxValue = maxHealth
	healthBar.value = (health / maxHealth) * 100
	#print("new enemy health: ", (health / maxHealth) * 100)
	
func updateCooldowns():
	if special1CoolDown >= 1:
		special1CoolDown -= 1
	if special2CoolDown >= 1:
		special2CoolDown -= 1
	if special3CoolDown >= 1:
		special3CoolDown -= 1
	return
