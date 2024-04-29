extends Node2D

class_name BattleMap

@onready var turn_queue = $"../TurnQueue"
@onready var tile_map = $TileMap
@onready var main_camera = $BattleCam
@onready var highlight_map = $HighlightMap
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var canMove: bool = false
var startMoving : bool = false
var doBucketFill : bool = true
var height : int = 9
var width : int = 9
var hazardPlaced : bool = false
var random_ColNum : int
var random_ExtraColNum : int
var random_ExtraColNum2 : int
var random_ExtraColNum3 : int
var random_SafeRowNum : int
var random_DangerRowNum : int
var random_DangerRowNum2 : int
var canAttack : bool = false
var tile_selected : Vector2i
var tile_selected_converted : Vector2
var skipMovement : bool = false

# Unit Storage
var friendlyUnits : Array
var Units : Array
var enemyUnits : Array
var currentPlayer : Node2D #Not being used everywhere is should
var currentEnemy : Node2D

# tile source IDs
var stonePath_source_id : int = 11
var StoneBasic_atlas = Vector2i(0,0)
var BarrelOnStone_source_id : int = 9
var CrateOnStone_source_id : int = 10

signal moveSelected
signal finishedMoving
signal characterMovementComplete
signal finishedGenerating
signal attackChosen
signal attackDone

# Called when the node enters the scene tree for the first time.
func initialize():
	randomize()
	main_camera.make_current()
	gatherUnitInfo()
	_generateMap()
	_makeAStarGrid()
	_loadBackground()
	canMove = false
	emit_signal("finishedGenerating")
	$BackgroundMusic.play()
	return
	
func _generateMap():
	tile_map.clear()
	random_SafeRowNum = randi_range(0, height - 1)
	random_DangerRowNum = randi_range(0, height - 1)
	random_DangerRowNum2 = randi_range(0, height - 1)
	for y in range(height): # reverse x and y for generation purposes
		random_ColNum = randi_range(1, width - 2)
		random_ExtraColNum = randi_range(1, width - 2)
		random_ExtraColNum2 = randi_range(1, width - 2)
		random_ExtraColNum3 = randi_range(1, width - 2)
		for x in range(width):
			if x == random_ColNum and y != random_SafeRowNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), BarrelOnStone_source_id, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), CrateOnStone_source_id, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), BarrelOnStone_source_id, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), CrateOnStone_source_id, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), BarrelOnStone_source_id, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), CrateOnStone_source_id, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), BarrelOnStone_source_id, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), CrateOnStone_source_id, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), stonePath_source_id, Vector2i(randi_range(0, 1), randi_range(0, 1)))
				
	return
	
func _makeAStarGrid():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32,32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
				)
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position, true)
	return
	
func update_AStarGrid():
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.update()
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
				)
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if (tile_data == null) or (tile_data.get_custom_data("walkable") == false):
				astar_grid.set_point_solid(tile_position, true) # can move if invalid tile
			else:	
				var UnitThere = false
				var global_tile_pos = tile_map.map_to_local(tile_position)
				for unit in Units:
					if unit.global_position == global_tile_pos:
						UnitThere = true
						break
				if UnitThere == true:
					astar_grid.set_point_solid(tile_position, true) # cant move if person there
					
	return
	
func get_AStarGrid() -> AStarGrid2D:
	return astar_grid
	
func get_TileMap():
	return tile_map
	
func _input(event):
	
	if canAttack == true:
		if event.is_action_pressed("move") == true:
			tile_selected = tile_map.local_to_map(get_global_mouse_position())
			canAttack = false
			emit_signal("attackChosen")
			return
			
	if event.is_action_pressed("move") == false: #nothing clicked
		return
		
	if canMove == true: # not allowed to move
		tile_selected = tile_map.local_to_map(get_global_mouse_position())
		tile_selected_converted = Vector2(tile_selected[0], tile_selected[1])
		canMove = false
		emit_signal("moveSelected")
	
	return
			
func getAllowedSpaces(x, y, max_moves : int, moves_made, spacesArray):
	var current_position = Vector2(x, y)
	spacesArray.append(current_position)
	
	# Base case: If moves made are equal to max_moves, stop recursion.
	if moves_made == max_moves:
		return
	
	# Directions for movement: up, down, left, right
	var directions = [
		Vector2(0, -1),  # Up
		Vector2(0, 1),   # Down
		Vector2(-1, 0),  # Left
		Vector2(1, 0)    # Right
	]
	
	# Explore all possible directions
	for direction in directions:
		var new_x = x + direction.x
		var new_y = y + direction.y
		
		var tile_position = Vector2(new_x, new_y)
		var tile_data = tile_map.get_cell_tile_data(0, tile_position)
	
		# Check bounds and if can go to the new cell
		if (tile_data != null) and (tile_data.get_custom_data("walkable") == true):
			var global_tile_pos = tile_map.map_to_local(tile_position)
			var noUnitThere = true
			for unit in Units:
				if unit.global_position == global_tile_pos:
					noUnitThere = false
					break
			if noUnitThere == true:
				getAllowedSpaces(new_x, new_y, max_moves, moves_made + 1, spacesArray)
			
	return
	
func movePerson(player):
	currentPlayer = player
	current_id_path.clear()
	# print("child ", player.get_index(), " waiting to pick")
	highlight_map._generateMoveMap(currentPlayer)
	highlight_map.highlightPlayer(currentPlayer)
	
	var starting_position = tile_map.local_to_map(currentPlayer.global_position)
	var allowedSpaces : Array = []
	getAllowedSpaces(starting_position[0], starting_position[1], currentPlayer.speed, 0, allowedSpaces)
	
	if len(allowedSpaces) >= 2:
		canMove = true
		await moveSelected
		if (tile_selected != starting_position): # skip move phase if staying still
			while (tile_selected_converted not in allowedSpaces): # make sure character allowed there
				print("Not in my house")
				canMove = true
				await moveSelected
				
			var global_tile_pos = tile_map.map_to_local(tile_selected)
			highlight_map.clear()
			var id_path = astar_grid.get_id_path(
			starting_position,
			tile_selected	
			).slice(1)

			if (id_path.is_empty() == false):
				current_id_path = id_path
			
			if (current_id_path.is_empty()):
				print("path error 2")
				return
			startMoving = true
			#print("await finishedmoving")
			await finishedMoving # wait for physics to finish moving
			#print("passed finished moving")
	highlight_map.clear()
	update_AStarGrid() # make sure we cant get by people
	emit_signal("characterMovementComplete")
	return
	
func _physics_process(_delta):
	if current_id_path.is_empty():
		return
	if startMoving == false:
		return

	target_position = tile_map.map_to_local(current_id_path.front())
	var activeUnit = turn_queue.get_active_character()
	activeUnit.global_position = activeUnit.global_position.move_toward(target_position, 3)
	
	if activeUnit.global_position == target_position:
		current_id_path.pop_front()
		if current_id_path.is_empty():
			startMoving = false
			#print("send finished moving")
			emit_signal("finishedMoving")
	return
	
func simpleAttack(player):
	currentPlayer = player
	canMove = false
	startMoving = false
	
	var starting_position = tile_map.local_to_map(currentPlayer.global_position)
	var attackOptions = []
	
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
		Vector2i(1, 0),   # Right
		Vector2i(-1, -1),
		Vector2i(1, 1),   
		Vector2i(-1, 1), 
		Vector2i(1, -1)  
	]
	
	for direction in directions:
		var calcDirection = starting_position + direction
		var enemyThere = false
		for unit in enemyUnits:
			if tile_map.local_to_map(unit.global_position) == calcDirection:
				enemyThere = true
				break
		if enemyThere == true:
			var tile_data = tile_map.get_cell_tile_data(0, calcDirection)
			if tile_data != null and tile_data.get_custom_data("walkable") == true:
				attackOptions.append(calcDirection)
				
	highlight_map.basicAttackGrid(starting_position)			
				
	if len(attackOptions) == 1:
		tile_selected = attackOptions[0]
		var global_tile_pos = tile_map.map_to_local(tile_selected)
		for unit in Units:
			if unit.global_position == global_tile_pos:
				unit.health -= currentPlayer.basicAttackDamage
				print("hit enemy!")
				break

	
	elif attackOptions.is_empty() == false:
		canAttack = true
		await attackChosen
		while tile_selected not in attackOptions:
			canAttack = true
			await attackChosen
			print("not good attack")
		var global_tile_pos = tile_map.map_to_local(tile_selected)
		for unit in Units:
			if unit.global_position == global_tile_pos:
				unit.health -= currentPlayer.basicAttackDamage
				print("hit enemy!")
				break
		
	canAttack = false
	highlight_map.clear()
	emit_signal("attackDone")
	
	return
	
func moveEnemyPerson(enemy): # move enemy randomly
	currentEnemy = enemy
	var enemy_position = currentEnemy.global_position
	var allowedSpaces : Array = []
	var starting_position = tile_map.local_to_map(enemy_position)
	getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	var attemptCounter = 0 #if we don't find a good random move in this many tries we just dont move
	var random_movePick
	while (validMove == false) and (attemptCounter <= 10):
		validMove = true
		attemptCounter += 1
		random_movePick = allowedSpaces.pick_random()
		
		var global_tile_pos = tile_map.map_to_local(random_movePick)
		for unit in Units:
			if unit.global_position == global_tile_pos:
				validMove = false
				break
				
	if attemptCounter <= 10:		
		current_id_path = astar_grid.get_id_path(
		starting_position,
		random_movePick	
		).slice(1)
		startMoving = true
		print("await2")
		await finishedMoving # wait for physics to finish moving
		
	else:
		print("chose to not move")
		emit_signal("finishedMoving")
	
	startMoving = false
	update_AStarGrid()
	emit_signal("characterMovementComplete")
	return
		
func agressiveEnemyMove(enemy): # move enemy to nearest player
	currentEnemy = enemy
	var enemy_position = currentEnemy.global_position
	var allowedSpaces : Array = []
	var starting_position = tile_map.local_to_map(enemy_position)
	getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	
	var smallestDistance = 999999
	var move_pick
	if allowedSpaces.is_empty() == false:
		for move in allowedSpaces:
			for playerUnit in friendlyUnits:
				var player_pos = tile_map.local_to_map(playerUnit.global_position)
				var distanceCalc = move.distance_to(player_pos)
				if distanceCalc < smallestDistance:
					validMove = true
					var global_move_pick = tile_map.map_to_local(move)
					for unit in Units:
						if unit.global_position == global_move_pick:
							validMove = false
							break
					if validMove == true:
						move_pick = move
						smallestDistance = distanceCalc
	else:
		move_pick = starting_position
	
	current_id_path = astar_grid.get_id_path(
	starting_position,
	move_pick	
	).slice(1)
	startMoving = true
	#print("awaitAgMove")
	await finishedMoving # wait for physics to finish moving
	#print("finishedAgMove")
	startMoving = false
	update_AStarGrid()
	emit_signal("characterMovementComplete")
	return
		
func cowardEnemyMove(enemy): # move enemy away from nearest player
	currentEnemy = enemy
	var enemy_position = currentEnemy.global_position
	var allowedSpaces : Array = []
	var starting_position = tile_map.local_to_map(enemy_position)
	var starting_position_convert = Vector2(starting_position[0], starting_position[1])
	var closestPlayer
	var closestPlayerDistance = 999999
	for unit in friendlyUnits: # get closest player
		var player_position = tile_map.local_to_map(unit.global_position)
		var distanceCalc = starting_position_convert.distance_to(player_position)
		if distanceCalc < closestPlayerDistance:
			closestPlayerDistance = distanceCalc
			closestPlayer = unit
	
	getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	
	var largestDistance = -999999
	var move_pick
	if allowedSpaces.is_empty() == false:
		for move in allowedSpaces: # find move that takes you farthest from closest player
			var player_pos = tile_map.local_to_map(closestPlayer.global_position)
			var distanceCalc = move.distance_to(player_pos)
			if distanceCalc > largestDistance:
				validMove = true
				var global_move_pick = tile_map.map_to_local(move)
				for unit in Units:
					if unit.global_position == global_move_pick:
						validMove = false
						break
				if validMove == true:
					move_pick = move
					largestDistance = distanceCalc
	else:
		move_pick = starting_position
	
	current_id_path = astar_grid.get_id_path(
	starting_position,
	move_pick	
	).slice(1)
	startMoving = true
	await finishedMoving # wait for physics to finish moving
	
	startMoving = false
	update_AStarGrid()
	emit_signal("characterMovementComplete")
	return		
		
func simpleEnemyAttack(enemy):
	currentEnemy = enemy
	var enemy_position = enemy.global_position
	var starting_position = tile_map.local_to_map(enemy_position)
	var attackOptions = []
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
		Vector2i(1, 0),   # Right
		Vector2i(-1, -1),
		Vector2i(1, 1),   
		Vector2i(-1, 1), 
		Vector2i(1, -1)  
	]
	
	for direction in directions:
		attackOptions.append(starting_position + direction)
	var attackTargets = []
	for option in attackOptions:
		for unit in friendlyUnits:
			if tile_map.local_to_map(unit.global_position) == option:
				attackTargets.append([option, unit])
	if attackTargets.is_empty() == false:
		var random_Choice = attackTargets.pick_random()
		var attacked_unit = random_Choice[1]
		attacked_unit.health -= currentEnemy.basicAttackDamage
		print("Player hit!")
		
	emit_signal("attackDone")
	
	return
	
func gatherUnitInfo():
	friendlyUnits = get_tree().get_nodes_in_group("PlayerUnits")
	Units = get_tree().get_nodes_in_group("Units")
	enemyUnits = get_tree().get_nodes_in_group("EnemyUnits")
	
	pass

func _loadBackground():
	pass
