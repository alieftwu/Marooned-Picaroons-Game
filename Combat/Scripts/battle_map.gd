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
	astar_grid.update()
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
				)
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				var noUnitThere = true
				var global_tile_pos = tile_map.map_to_local(tile_position)
				for unit in Units:
					if unit.global_position == global_tile_pos:
						noUnitThere = false
						break
				if noUnitThere == true:
					astar_grid.set_point_solid(tile_position, true)
					
	astar_grid.update()
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
			
	if canMove == false: # not allowed to move
		return
	
	if event.is_action_pressed("move") == false: #nothing clicked
		return
	
	var id_path
	var clicked_tile = tile_map.local_to_map(get_global_mouse_position())
	# get all possible spaces you can move to
	var starting_position = tile_map.local_to_map(currentPlayer.global_position)
	var allowedSpaces : Array = []
	getAllowedSpaces(starting_position[0], starting_position[1], currentPlayer.speed, 0, allowedSpaces)
	
	clicked_tile = Vector2(clicked_tile[0], clicked_tile[1]) # make it a vector
	
	if (clicked_tile == Vector2(starting_position[0], starting_position[1])): # skip move phase
		skipMovement = true
	else:
		skipMovement = false
		
	print(clicked_tile)
	print(allowedSpaces)
	if (clicked_tile not in allowedSpaces) and (skipMovement == false): # make sure character has speed to move there
		print("Not in my house")
		return
		
	var global_tile_pos = tile_map.map_to_local(clicked_tile)
	for unit in Units:
		if (unit.global_position == global_tile_pos) and (skipMovement == false):
			print("Person already there")
			return
			
	# print("child ", currentPlayer.get_index(), " clicked tile: " + str(clicked_tile))
	id_path = astar_grid.get_id_path(
	starting_position,
	tile_map.local_to_map(get_global_mouse_position())	
	).slice(1)

	if (id_path.is_empty() == false):
		current_id_path = id_path
	
	if (current_id_path.is_empty()) and (skipMovement == false):
		return
		
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
	canMove = true
	# print("child ", player.get_index(), " waiting to pick")
	highlight_map._generateMoveMap(currentPlayer)
	await moveSelected # wait for person to select valid spot to move
	highlight_map.clear()
	if (skipMovement == false):
		# print("child ", player.get_index(), " started moving")
		target_position = tile_map.map_to_local(current_id_path.front())
		
		startMoving = true
		await finishedMoving # wait for physics to finish moving
	skipMovement = false
	update_AStarGrid()
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
			emit_signal("finishedMoving")
			print("child ", activeUnit.get_index(), " finished moving")
			print(activeUnit.global_position)
	return
	
func simpleAttack(player):
	currentPlayer = player
	canAttack = true
	canMove = false
	startMoving = false
	print("1")
	
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
		attackOptions.append(starting_position + direction)
	
	highlight_map.basicAttackGrid(starting_position)
	
	print("2")
	await attackChosen
	print("3")
	while tile_selected not in attackOptions:
		canAttack = true
		await attackChosen
		print("not good attack")
	print("4")
	var global_tile_pos = tile_map.map_to_local(tile_selected)
	for unit in Units:
		if unit.global_position == global_tile_pos:
			unit.health -= currentPlayer.basicAttackDamage
			print("hit him!")
			break
		
	canAttack = false
	highlight_map.clear()
	print("5")
	emit_signal("attackDone")
	
	return
	
func moveEnemyPerson(enemy):
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
		await finishedMoving # wait for physics to finish moving
		
	else:
		print("chose to not move")
		emit_signal("finishedMoving")
	
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
