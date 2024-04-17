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

# tile source IDs
var stoneTile_source_id : int = 5
var rockStoneTile_source_id : int = 6

signal moveSelected
signal finishedMoving
signal characterMovementComplete
signal finishedGenerating

# Called when the node enters the scene tree for the first time.
func initialize():
	randomize()
	main_camera.make_current()
	_generateMap()
	_makeAStarGrid()
	_spawnPlayers()
	_spawnEnemies()
	_loadBackground()
	_startMusic()
	canMove = false
	emit_signal("finishedGenerating")
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
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), stoneTile_source_id, Vector2i(0, 0))
				
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
	
func get_AStarGrid() -> AStarGrid2D:
	return astar_grid
	
func get_TileMap():
	return tile_map
	
func _input(event):
	if canMove == false: # not allowed to move
		return
	
	if event.is_action_pressed("move") == false: #nothing clicked
		return
	
	var id_path
	var clicked_tile = tile_map.local_to_map(get_global_mouse_position())
	# get all possible spaces you can move to
	var player = turn_queue.get_active_character()
	var starting_position = tile_map.local_to_map(player.global_position)
	var allowedSpaces : Array = []
	getAllowedSpaces(starting_position[0], starting_position[1], player.stats.Speed, 0, allowedSpaces)
	
	clicked_tile = Vector2(clicked_tile[0], clicked_tile[1]) # make it a vector
	
	if clicked_tile not in allowedSpaces: # make sure character has speed to move there
		print("Not in my house")
		return
	print("child ", player.get_index(), " clicked tile: " + str(clicked_tile))
	id_path = astar_grid.get_id_path(
	starting_position,
	tile_map.local_to_map(get_global_mouse_position())	
	).slice(1)

	if id_path.is_empty() == false:
		current_id_path = id_path
	
	if current_id_path.is_empty():
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
			getAllowedSpaces(new_x, new_y, max_moves, moves_made + 1, spacesArray)
	return
	
func movePerson(player):
	current_id_path.clear()
	canMove = true
	print("child ", player.get_index(), " waiting to pick")
	highlight_map._generateMoveMap(player)
	await moveSelected # wait for person to select valid spot to move
	highlight_map.clear()
	print("child ", player.get_index(), " started moving")
	target_position = tile_map.map_to_local(current_id_path.front())
	
	startMoving = true
	await finishedMoving # wait for physics to finish moving
	emit_signal("characterMovementComplete")
	return
	
func _physics_process(delta):
	if current_id_path.is_empty():
		return
	if startMoving == false:
		return
	print(current_id_path)
	target_position = tile_map.map_to_local(current_id_path.front())
	var player = turn_queue.get_active_character()
	player.global_position = player.global_position.move_toward(target_position, 3)
	
	if player.global_position == target_position:
		current_id_path.pop_front()
		if current_id_path.is_empty():
			print(current_id_path)
			startMoving = false
			emit_signal("finishedMoving")
			print("child ", player.get_index(), " finished moving")
		#current_id_path.clear()
	
	return
	
#func _physics_process(delta):
	#if current_id_path.is_empty():
		#return
	#if startMoving == false:
		#return
		#
	#target_position = tile_map.map_to_local(current_id_path.front())
	#var person_node = turn_queue.get_active_character()
	#person_node.global_position = person_node.global_position.move_toward(target_position, 3)
	#
	#if person_node.global_position == target_position:
		#current_id_path.pop_front()
		#startMoving == false
		#emit_signal("finishedMoving")
	#return
	
func _spawnPlayers():
	pass
	
func _spawnEnemies():
	pass

func _loadBackground():
	pass

func _startMusic():
	pass
