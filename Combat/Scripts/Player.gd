extends Node2D

@onready var battlemap = $"../../BattleMap"
@onready var highlightmap = $"../../BattleMap/HighlightMap"
@onready var abilityControl = $"../../BattleMap/AbilityControl"
@onready var healthBar = $HealthBar
@onready var statusEffect = $StatusEffect
var stats = load("res://Combat/Resources/playertest.tres")
var speed : int
var health : float
var maxHealth : float
var armor : int
var basicAttackDamage : int
var passiveAbility = {
	0: "evasive",
	1: "Bomber",
	2: "Sniper"
}
#buttons 2-4 abilities. can switch out
var abilityList = {
	0: ["pirateBlessing", "circleSlash", "quickStrike"], #white companion2
	1: ["bombThrow" , "circleSlash", "takeDown"], #red companion2
	2: ["heavySwordSwing" , "rapidFire", "desparateStrike"], #yellow companion2
} 

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
	speed = 3
	health = 100 * Global.statsMultiplier
	print("Start Health: ", health)
	maxHealth = 100 * Global.statsMultiplier
	armor = 2 * Global.statsMultiplier
	basicAttackDamage = 15 * Global.statsMultiplier
	setAbilities(Global.second_companion)
	setPassives(Global.second_companion)
func play_turn():
	updateHealthBar()
	abilityControl.checkBlocking(self)
	isBlocking = false
	var skipTurn = await abilityControl.checkStun(self)
	if isStunned == true:
		updateStatusEffect()
	if skipTurn == false:
		await abilityControl.checkFlags(self)
		await battlemap.setAttackIconsDull() # make buttons dull
		await battlemap.movePerson(self)
		await battlemap.checkCooldownIcons(self) # updates buttons with cooldown icons
		await battlemap.updateButtons(self)
		canPress = true
		await battlemap.abilityFinished
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

func updateStatusEffect():
	var effect
	if isStunned == true:
		effect = load("res://Combat/Resources/stunned.png")
		statusEffect.texture = effect
	else:
		statusEffect.texture = null

func setAbilities(spriteIndex):
	if spriteIndex in abilityList:
		abilityList = abilityList[spriteIndex]
	else:
		#Default abilities
		print("setting to default ability combination")
		abilityList = ["rapidFire", "quickStrike", "pirateBlessing"]

func setPassives(spriteIndex):
	if spriteIndex in passiveAbility:
		passiveAbility = passiveAbility[spriteIndex]
	else:
		#default passive
		print("setting to default passive: ShotPrediction")
		passiveAbility = "ShotPrediction"
