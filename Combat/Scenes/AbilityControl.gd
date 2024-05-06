extends Node2D

@onready var battle_map = get_parent()
@onready var tile_map = get_node("../TileMap")
@onready var turn_queue = $"../../TurnQueue"
@onready var highlight_map = get_node("../HighlightMap")
@onready var abilityMusic = $"../abilityMusic"

var astar_grid: AStarGrid2D
var height : int = 9
var width : int = 9
var speed : int = 1
var starting_location
var tile_data
var current_position : Vector2i
var currentPlayer : Node2D
var chooseAttack = false # set tp true when you want mouse input
var tile_selected : Vector2i
var interactUnit : Node2D # unit we are attacking / healing etc
signal specialAttackChosen
signal specialAttackDone # not in use currently

# Called when the node enters the scene tree for the first time.
func _ready():
	await battle_map.finishedGenerating
	height = battle_map.height
	width = battle_map.width
	astar_grid = battle_map.astar_grid

func _input(event):
	
	if chooseAttack == true:
		if event.is_action_pressed("move") == true:
			tile_selected = tile_map.local_to_map(get_global_mouse_position())
			chooseAttack = false
			emit_signal("specialAttackChosen")
			return

func checkFlags(player): # will check and see if certain conditions have been meet for abilities
	if player.frenzyBuff == true:
		player.frenzyBuffCount -= 1
		if player.frenzyBuffCount == 0:
			player.frenzyBuff = false
			player.speed -= 1
			player.basicAttackDamage -= 10
	return
	
func checkBlocking(unit):
	if unit.isBlocking == true: # keep unit from being stunned by updating didBlock
		if unit.didBlock == false:
			unit.didBlock = true
	return
	
func checkStun(player):
	var skipTurn = false
	if player.isStunned == true:
		skipTurn = true
		player.isStunnedCount -= 1
		if player.isStunnedCount == 0:
			player.isStunned = false
	if player.isBlocking == true:
		if player.didBlock == false:
			player.isStunned = true
			player.isStunnedCount = 2
			skipTurn = true
		else:
			player.didBlock = false
	if player.passiveAbility == "unflinching":
		skipTurn = false
	return skipTurn
	
func checkPassiveAttack(player, potentialDamage = 0, damageType = null): # check passive ability
	var damageModifier : float = 1.0
	if player.passiveAbility == "Brawler":
		if damageType == "Melee":
			damageModifier = 1.25
			print("Brawler")
	elif player.passiveAbility == "Bomber":
		if damageType == "Bomb":
			damageModifier = 1.4
			print("Bomber")
	elif player.passiveAbility == "Sniper":
		if damageType == "Ranged":
			damageModifier = 1.3
			print("Sniper")
	elif player.passiveAbility == "ninja":
			damageModifier = 0.8
			print("Ninja")
	# unflinching passive makes it so you can't be stunned		
			
	return damageModifier
	
func checkPassiveDefend(player, potentialDamage = 0, damageType = null): # check passive ability
	var damageModifier : float = 1.0
	var testMusic = load("res://Combat/Resources/block.wav")
	if player.passiveAbility == "ShotPrediction":
		if damageType == "Ranged":
			damageModifier = 0.65
			print("ShotPrediction")
	elif player.passiveAbility == "steelSkin":
		if damageType == "Melee":
			damageModifier = 0.10
			print("steelSkin")
			testMusic = load("res://Combat/Resources/block.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
	elif player.passiveAbility == "leatherSkin":
		if damageType == "Melee":
			damageModifier = 0.70
			print("leatherSkin")
	elif player.passiveAbility == "hardToHit":
		if damageType == "Throw":
			damageModifier = 0
			print("hardToHit")
			testMusic = load("res://Combat/Resources/dodge.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
	elif player.passiveAbility == "evasive":
		if randf() < 0.2:
			damageModifier = 0
			print("evasive")
			testMusic = load("res://Combat/Resources/dodge.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
	elif player.passiveAbility == "ninja":
		if randf() < 0.5:
			damageModifier = 0
			print("ninja")
			testMusic = load("res://Combat/Resources/dodge.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
	elif player.passiveAbility == "ghost":
		if randf() < 0.7:
			damageModifier = 0
			print("ghost")
			testMusic = load("res://Combat/Resources/dodge.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
	if player.isBlocking == true: # if they are blocking negate all damage
		damageModifier = 0.0
		player.didBlock = true
		testMusic = load("res://Combat/Resources/block.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	return damageModifier
	
func checkTeam(player): # check what team the calling player is on
	var isPlayer = true
	if player in battle_map.enemyUnits:
		isPlayer = false
	return isPlayer

func checkMoveSlot(player, ability): # see what the players move for that button is and call it
	var cooldown : int = 0
	if ability == "pistolShot":
		print("pistolShot")
		await pistolShot(player)
		cooldown = 2
	elif ability == "heavySwordSwing":
		print("heavySwordSwing")
		await heavySwordSwing(player)
		cooldown = 2
	elif ability == "recklessFrenzy":
		print("recklessFrenzy")
		await recklessFrenzy(player)
		cooldown = 3
	elif ability == "takeDown":
		print("takeDown")
		await takeDown(player)
		cooldown = 4
	elif ability == "pirateBlessing":
		print("pirateBlessing")
		await pirateBlessing(player)
		cooldown = 2
	elif ability == "axeToss":
		print("axeToss")
		await axeToss(player)
		cooldown = 3
	elif ability == "quickStrike":
		print("quickStrike")
		await quickStrike(player)
		cooldown = 2
	elif ability == "circleSlash":
		print("circleSlash")
		await circleSlash(player)
		cooldown = 1
	elif ability == "desparateStrike":
		print("desparateStrike")
		await desparateStrike(player)
		cooldown = 1
	elif ability == "rapidFire":
		print("rapidFire")
		await rapidFire(player)
		cooldown = 3
	elif ability == "cannonShot":
		print("cannonShot")
		await cannonShot(player)
		cooldown = 2
	elif ability == "engagingBlock":
		print("engagingBlock")
		await engagingBlock(player)
		cooldown = 3
	elif ability == "bombThrow":
		print("bombThrow")
		await bombThrow(player)
		cooldown = 3
	elif ability == "damageWave":
		print("damageWave")
		await damageWave(player)
		cooldown = 4
	elif ability == "spawnMinion":
		print("spawnMinion")
		await spawnMinion(player)
		cooldown = 2
	return cooldown
	
func checkEnemyPresent(targetSpace, isPlayer): # see if unit from other team is there
	var enemyThere = false
	var targetUnit
	if isPlayer == true:
		for unit in battle_map.enemyUnits:
			if tile_map.local_to_map(unit.global_position) == targetSpace:
				enemyThere = true
				targetUnit = unit
				break
	elif isPlayer == false:
		for unit in battle_map.friendlyUnits:
			if tile_map.local_to_map(unit.global_position) == targetSpace:
				enemyThere = true
				targetUnit = unit
				break
	return enemyThere
	
func checkUnitThere(targetSpace, isPlayer): # see if a unit is on that space
	var unitThere = false
	var targetUnit
	for unit in battle_map.Units:
		if tile_map.local_to_map(unit.global_position) == targetSpace:
			unitThere = true
			break
	return unitThere
	
func checkTileData(targetSpace): #see if tile has certain properties
	var validTile = false
	tile_data = tile_map.get_cell_tile_data(0, targetSpace)
	if (tile_data != null) and (tile_data.get_custom_data("walkable") == true):
		validTile = true
	return validTile
	
func checkTileDataPierce(targetSpace): #see if tile has certain properties	
	var validTile = false
	tile_data = tile_map.get_cell_tile_data(0, targetSpace)
	if (tile_data != null):
		validTile = true
	return validTile
	
func getTarget(targetSpace): # get unit at target space
	var targetUnit = null
	for unit in battle_map.Units:
		if tile_map.local_to_map(unit.global_position) == targetSpace:
			targetUnit = unit
			break
	return targetUnit
	
func lineFind(x, y, moves_made, max_moves, direction, spacesArray, isPlayer):
	var new_position = Vector2i(x, y)
	
	if moves_made == max_moves:
		return
	if direction == "left":
		new_position += Vector2i(1,0)
	elif direction == "right":
		new_position += Vector2i(-1,0)
	elif direction == "up":
		new_position += Vector2i(0,1)
	elif direction == "down":
		new_position += Vector2i(0,-1)
	else:
		print("invalid direction for lineFind")
		return
	
	var enemyThere = checkEnemyPresent(new_position, isPlayer)
	var unitThere = checkUnitThere(new_position, isPlayer)
	var validTile = checkTileData(new_position)
	if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
		spacesArray.append(new_position)
		highlight_map.highlightRed(new_position)
	
	moves_made += 1
	if validTile and unitThere == false: # can't shoot this through units
		lineFind(new_position.x, new_position.y, moves_made, max_moves, direction, spacesArray, isPlayer)
	
func lineFindPierce(x, y, moves_made, max_moves, direction, spacesArray, isPlayer):
	var new_position = Vector2i(x, y)
	
	if moves_made == max_moves:
		return
	if direction == "left":
		new_position += Vector2i(1,0)
	elif direction == "right":
		new_position += Vector2i(-1,0)
	elif direction == "up":
		new_position += Vector2i(0,1)
	elif direction == "down":
		new_position += Vector2i(0,-1)
	else:
		print("invalid direction for lineFind")
		return
	
	var enemyThere = checkEnemyPresent(new_position, isPlayer)
	var validTile = checkTileDataPierce(new_position)
	if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
		spacesArray.append(new_position)
		highlight_map.highlightRed(new_position)
	
	moves_made += 1
	if validTile:
		lineFindPierce(new_position.x, new_position.y, moves_made, max_moves, direction, spacesArray, isPlayer)	
	return
	
func areaFind(x, y, moves_made, max_moves, spacesArray, isPlayer): # find spaces in an area
	var current_position = Vector2i(x, y)
	
	# Base case: If moves made are equal to max_moves, stop recursion.
	if moves_made == max_moves:
		return
	
	# Directions for movement: up, down, left, right
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
		Vector2i(1, 0)    # Right
	]
	
	moves_made += 1
	
	# Explore all possible directions
	for direction in directions:
		var new_x = x + direction.x
		var new_y = y + direction.y
		
		var new_position = Vector2i(new_x, new_y)
		var enemyThere = checkEnemyPresent(new_position, isPlayer)
		var validTile = checkTileData(new_position)
		if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
			if new_position not in spacesArray: # make sure its a unique space
				spacesArray.append(new_position)
				highlight_map.highlightRed(new_position)
		
		if validTile:
			areaFind(new_x, new_y, moves_made, max_moves, spacesArray, isPlayer)		
	return
	
func aroundFind(startSpace, max_moves, spacesArray, isPlayer): # find spaces around spot (includes diagnols) (up to 3)
	# Base case: If moves made are equal to max_moves, stop recursion.
	var new_position : Vector2i
	var enemyThere
	var validTile
	# Directions for movement: up, down, left, right
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
		Vector2i(1, 0) ,   # Right
		Vector2i(-1, -1),  
		Vector2i(1, 1),   
		Vector2i(-1, 1),  
		Vector2i(1, -1)    
	]
	
	# Explore all possible directions
	for direction in directions:
		
		new_position = startSpace + direction
		enemyThere = checkEnemyPresent(new_position, isPlayer)
		validTile = checkTileData(new_position)
		if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
			if new_position not in spacesArray: # make sure its a unique space
				spacesArray.append(new_position)
				highlight_map.highlightRed(new_position)
	if max_moves >= 2:
		for direction in directions:
			new_position = startSpace + (direction * 2)
			enemyThere = checkEnemyPresent(new_position, isPlayer)
			validTile = checkTileData(new_position)
			if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
				if new_position not in spacesArray: # make sure its a unique space
					spacesArray.append(new_position)
					highlight_map.highlightRed(new_position)
	if max_moves >= 3:
		for direction in directions:
			new_position = startSpace + (direction * 3)
			enemyThere = checkEnemyPresent(new_position, isPlayer)
			validTile = checkTileData(new_position)
			if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
				if new_position not in spacesArray: # make sure its a unique space
					spacesArray.append(new_position)
					highlight_map.highlightRed(new_position)
	return
	
func pistolShot(player): #shoot in a line 3 away
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 4, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 4, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 4, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 4, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Range")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Range")
		checkBlocking(interactUnit)
		interactUnit.health -= (player.basicAttackDamage * 2 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.updateHealthBar()
		
		var testMusic = load("res://Combat/Resources/pistol.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func heavySwordSwing(player): # only works if next to person, 1 tile range
	
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 1, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Melee")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Melee")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 2 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func recklessFrenzy(player): # increase speed and attack at cost of health for 2 turns
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var buffTargets : Array = []
	var attackChoice = null
	aroundFind(starting_position, 1, buffTargets, isPlayer)
	var testMusic = load("res://Combat/Resources/damageWaveSound.wav")
	abilityMusic.stream = testMusic
	abilityMusic.play()
	player.speed += 1
	player.basicAttackDamage += 10
	player.health -= 10
	player.frenzyBuff = true
	player.frenzyBuffCount = 3 # to tell when 2 turns are up
	
	for space in buffTargets:	
		interactUnit = getTarget(space)
		interactUnit.speed += 1
		interactUnit.basicAttackDamage += 10
		interactUnit.health -= 10
		interactUnit.updateHealthBar()
		interactUnit.frenzyBuff = true
		interactUnit.frenzyBuffCount = 3 # lasts 2 turns
		
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func takeDown(player): # must have ally next to you, damage and stun nearby opponent for 2-3 turns. Ignores armor
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 1, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "down", attackTargets, isPlayer)
	
	var allyList : Array = []
	aroundFind(starting_position, 1, allyList, !isPlayer) # find ally around you
	for unit in allyList:
		highlight_map.clearTile(unit)
	if (attackTargets.is_empty() == false) and (allyList.is_empty() == false):
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Melee")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Melee")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 2 * attackModifier * defendModifier)
		interactUnit.health -= damage
		await battle_map.updateDamageDisplay(interactUnit, damage)
		interactUnit.updateHealthBar()
		interactUnit.isStunned = true
		interactUnit.isStunnedCount = 3 # 2 turns
		if interactUnit.passiveAbility != "unflinching":
			interactUnit.updateStatusEffect()
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func pirateBlessing(player): #heal any friend on the map a little
	var isPlayer = checkTeam(player)
	var healTargets : Array = []
	var healChoice = null
	var healTile = null
	
	if isPlayer:
		for unit in battle_map.friendlyUnits:
			var unit_position = tile_map.local_to_map(unit.global_position)
			highlight_map.highlightRed(unit_position)
			healTargets.append(unit_position)
		chooseAttack = true
		await specialAttackChosen
		while tile_selected not in healTargets:
			chooseAttack = true
			await specialAttackChosen
		healChoice = getTarget(tile_selected)
	else:
		healChoice = battle_map.enemyUnits.pick_random()
	var healerModifier = checkPassiveAttack(player, 0, "Heal")
	var healedModifier = checkPassiveDefend(healChoice, 0, "Heal")
	var health = 25 * healedModifier * healerModifier
	healChoice.health += health
	if healChoice.health > healChoice.maxHealth:
		healChoice.health = healChoice.maxHealth
	healChoice.updateHealthBar()
	await battle_map.updateDamageDisplayHeal(healChoice, health)
	var testMusic = load("res://Combat/Resources/damageWaveSound.wav")
	abilityMusic.stream = testMusic
	abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func axeToss(player): # toss axe that can go over obstacles, must be 2-3 away from you
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "left", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "right", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "up", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Throw")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Throw")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 1.75 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func quickStrike(player): # attack then you can move again
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 1, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Melee")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Melee")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 1.2 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	player.bonusMove = true
	emit_signal("specialAttackDone")
	return
	
func circleSlash(player): # hit all enemies around you for 1.5 basic
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	aroundFind(starting_position, 1, attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		for targetSpace in attackTargets:
			interactUnit = getTarget(targetSpace)
			var attackModifier = checkPassiveAttack(player, 0, "Melee")
			var defendModifier = checkPassiveDefend(interactUnit, 0, "Melee")
			checkBlocking(interactUnit)
			var damage = (player.basicAttackDamage * 1.3 * attackModifier * defendModifier) - interactUnit.armor
			interactUnit.health -= damage
			interactUnit.updateHealthBar()
			await battle_map.updateDamageDisplay(interactUnit, damage)
			abilityMusic.stream = testMusic
			abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func desparateStrike(player): # deal more damage if low health 1 away !!!!! need max health stat!!!!!!!
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 1, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 1, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Melee")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Melee")
		var moveModifier = 1.0
		if (player.health <= 20):
			moveModifier = 2.4
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 1.25 * attackModifier * defendModifier * moveModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func rapidFire(player): # hit two enemies in range 2 around you for .75 basic
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	areaFind(starting_position.x, starting_position.y, 0, 2, attackTargets, isPlayer)
	var areTwoTargets = true
	if len(attackTargets) <= 1: # so we know to move on if only 1 target
		areTwoTargets = false
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		var index = attackTargets.find(attackChoice)
		attackTargets.remove_at(index)
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Ranged")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Ranged")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 0.75 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/pistol.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
		highlight_map.clearTile(attackChoice)
		
		if areTwoTargets == true: # second attack
			if isPlayer == true:
				chooseAttack = true
				await specialAttackChosen
				while tile_selected not in attackTargets:
					chooseAttack = true
					await specialAttackChosen
				attackChoice = tile_selected
			else:
				attackChoice = attackTargets.pick_random()
				
			interactUnit = getTarget(attackChoice)
			attackModifier = checkPassiveAttack(player, 0, "Ranged")
			defendModifier = checkPassiveDefend(interactUnit, 0, "Ranged")
			checkBlocking(interactUnit)
			damage = (player.basicAttackDamage * 0.75 * attackModifier * defendModifier) - interactUnit.armor
			interactUnit.health -= damage
			interactUnit.updateHealthBar()
			await battle_map.updateDamageDisplay(interactUnit, damage)
			testMusic = load("res://Combat/Resources/pistol.wav")
			abilityMusic.stream = testMusic
			abilityMusic.play()
			
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func cannonShot(player): #cannon attack in a line, you skip next turn ignores armor
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 9, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 9, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 9, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 9, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Range")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Range")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 4 * attackModifier * defendModifier)
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
	player.isStunned = true
	player.isStunnedCount = 3 # 2 turn
	player.updateStatusEffect()
	var testMusic = load("res://Combat/Resources/pistol.wav")
	abilityMusic.stream = testMusic
	abilityMusic.play()
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func engagingBlock(player): # block all attacks until your next turn, if not hit stunned for 2 turns
	player.isBlocking = true
	var testMusic = load("res://Combat/Resources/block.wav")
	abilityMusic.stream = testMusic
	abilityMusic.play()
	emit_signal("specialAttackDone")
	return

func bombThrow(player): # throw bomb that hits units nearby as well
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "left", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "right", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "up", attackTargets, isPlayer)
	lineFindPierce(starting_position.x, starting_position.y, 0, 3, "down", attackTargets, isPlayer)
	
	if attackTargets.is_empty() == false:
		if isPlayer == true:
			chooseAttack = true
			await specialAttackChosen
			while tile_selected not in attackTargets:
				chooseAttack = true
				await specialAttackChosen
			attackChoice = tile_selected
		else:
			attackChoice = attackTargets.pick_random()
			
		interactUnit = getTarget(attackChoice)
		var attackModifier = checkPassiveAttack(player, 0, "Bomb")
		var defendModifier = checkPassiveDefend(interactUnit, 0, "Bomb")
		checkBlocking(interactUnit)
		var damage = (player.basicAttackDamage * 2 * attackModifier * defendModifier) - interactUnit.armor
		interactUnit.health -= damage
		interactUnit.updateHealthBar()
		await battle_map.updateDamageDisplay(interactUnit, damage)
		var testMusic = load("res://Combat/Resources/pistol.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
		
		# find units around for splash damage
		var splashTargets : Array = []
		aroundFind(attackChoice, 1, splashTargets, isPlayer)
		aroundFind(attackChoice, 1, splashTargets, !isPlayer) # teammates to
		print("splash: ", splashTargets)
		for unitSpace in splashTargets:
			interactUnit = getTarget(unitSpace)
			attackModifier = checkPassiveAttack(player, 0, "Range")
			defendModifier = checkPassiveDefend(interactUnit, 0, "Range")
			checkBlocking(interactUnit)
			damage = (player.basicAttackDamage * 2 * attackModifier * defendModifier) - interactUnit.armor
			interactUnit.health -= damage
			interactUnit.updateHealthBar()
			await battle_map.updateDamageDisplay(interactUnit, damage)
			
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return

func damageWave(player): # deal damage to entire enemy team from 50% to 250%
	
	var isPlayer = checkTeam(player)
	var testMusic = load("res://Combat/Resources/damageWaveSound.wav")
	if isPlayer:
		for unit in battle_map.enemyUnits:
			interactUnit = unit
			var attackModifier = checkPassiveAttack(player, 0, "Range")
			var defendModifier = checkPassiveDefend(interactUnit, 0, "Range")
			checkBlocking(interactUnit)
			var damage = (player.basicAttackDamage * randf_range(0.5, 2.5) * attackModifier * defendModifier) - interactUnit.armor
			interactUnit.health -= damage
			interactUnit.updateHealthBar()
			abilityMusic.stream = testMusic
			abilityMusic.play()
			await battle_map.updateDamageDisplay(interactUnit, damage)
	else:
		for unit in battle_map.friendlyUnits:
			interactUnit = unit
			var attackModifier = checkPassiveAttack(player, 0, "Range")
			var defendModifier = checkPassiveDefend(interactUnit, 0, "Range")
			checkBlocking(interactUnit)
			var damage = (player.basicAttackDamage * randf_range(0.5, 2.5) * attackModifier * defendModifier) - interactUnit.armor
			interactUnit.health -= damage
			interactUnit.updateHealthBar()
			abilityMusic.stream = testMusic
			abilityMusic.play
			await battle_map.updateDamageDisplay(interactUnit, damage)
			
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return

func spawnMinion(player):
	var spawnLocations : Array = [Vector2i(136,8), Vector2i(136,24), Vector2i(136,40), Vector2i(136,56), Vector2i(136,72),
	 Vector2i(136,88),Vector2i(136,104), Vector2i(136,120), Vector2i(136,136)]
	for location in spawnLocations:
		var starting_position = tile_map.local_to_map(location)
		var unitThere = false
		if checkEnemyPresent(starting_position, true) or checkEnemyPresent(starting_position, false):
			unitThere = true
			break
		if unitThere == false:
			var newMinionSource = load("res://Combat/Resources/damageWaveSound.wav")
			var locationConvert : Vector2 = location
			var newMinion = newMinionSource.instantiate()
			turn_queue.add_child(newMinion)
			print("current: ", newMinion.global_position)
			print("want to be: ", locationConvert)
			# var globalPos = battle_map.tile_map.map_to_local(locationConvert)
			newMinion.global_position = locationConvert
			break
	return
