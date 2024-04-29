extends Node2D

@onready var battle_map = get_parent()
@onready var tile_map = get_node("../TileMap")
@onready var turn_queue = $"../../TurnQueue"
@onready var highlight_map = get_node("../HighlightMap")

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
	pass

func checkPassive(player): # check passive ability
	pass
	
func checkTeam(player): # check what team the calling player is on
	var isPlayer = true
	if player in battle_map.enemyUnits:
		isPlayer = false
	return isPlayer

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
	
func checkTileData(targetSpace): #see if tile has certain properties
	var validTile = false
	tile_data = tile_map.get_cell_tile_data(0, targetSpace)
	if (tile_data != null) and (tile_data.get_custom_data("walkable") == true):
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
	var validTile = checkTileData(new_position)
	if enemyThere and validTile: # if a unit from other team is there, add to possible attack spaces
		spacesArray.append(new_position)
		highlight_map.highlightRed(new_position)
	
	moves_made += 1
	if validTile:
		lineFind(new_position.x, new_position.y, moves_made, max_moves, direction, spacesArray, isPlayer)
	
func pistolShot(player): #shoot in a line 3 away
	var starting_position = tile_map.local_to_map(player.global_position)
	var isPlayer = checkTeam(player)
	var attackTargets : Array = []
	var attackChoice = null
	lineFind(starting_position.x, starting_position.y, 0, 3, "left", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 3, "right", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 3, "up", attackTargets, isPlayer)
	lineFind(starting_position.x, starting_position.y, 0, 3, "down", attackTargets, isPlayer)
	
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
		interactUnit.health -= (player.basicAttackDamage * 2)
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
		interactUnit.health -= (player.basicAttackDamage * 3)
	highlight_map.clear()
	emit_signal("specialAttackDone")
	return
	
func recklessFrenzy(player): # increase speed and attack at cost of health for 2 turns
	pass
func takeDown(player): # must have ally next to you, damage and stun nearby opponent for 2-3 turns
	pass
func pirateBlessing(player): #heal any friend on the map a little
	pass
func axeToss(player): # toss axe that can go over obstacles, must be 2-3 away from you
	pass
func piercingShot(player): # hit all units(including players if that doesnt break anything) in a line of 4
	pass
func quickStrike(player): # gain 1 speed, attack like basic then you can move again
	pass
func circleSlash(player): # hit all enemies around you for 1.5 basic
	pass
func desparateStrike(player): # deal more damage if low health 1 away
	pass
func rapidFire(player): # hit two enemies in range 2 around you for .75 basic
	pass
func cannonShot(player): #cannon attack in a line, you skip next turn
	pass
func cleverInsults(player): #taunt AI for a turn
	pass
func engagingBlock(player): # block all attacks until your next turn, if not hit stuned for 2 turns
	pass
