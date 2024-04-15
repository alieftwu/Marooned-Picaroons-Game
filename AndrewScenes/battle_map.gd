extends Node2D

@onready var tile_map = $TileMap
@onready var main_camera = $BattleCam
@onready var player = $Player
@onready var highlight_map = $HighlightMap
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var canMove: bool = false
var startMoving : bool = false
var person_node : Node2D
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
signal finishedGenerating

# Called when the node enters the scene tree for the first time.
func _ready():
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
	print("clicked tile: " + str(clicked_tile))
	id_path = astar_grid.get_id_path(
	tile_map.local_to_map(person_node.global_position),
	tile_map.local_to_map(get_global_mouse_position())	
	).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
	
	if current_id_path.is_empty():
		return
		
	canMove = false
	emit_signal("moveSelected")
	return
			
func highlight_tile(tile_pos):
	#highlight_tilemap.clear()  # Clear previous highlights
	#highlight_tilemap.set_cellv(tile_pos, 0)  # Set a highlight tile at the clicked position
	pass
	
func movePerson(person : Node2D):
	person_node = person
	canMove = true
	print("wait to pick")
	
	highlight_map._generateMoveMap(person_node)
	await moveSelected # wait for person to select valid spot to move
	highlight_map.clear()
	print("moving")
	target_position = tile_map.map_to_local(current_id_path.front())
	
	startMoving = true
	await finishedMoving # wait for physics to finish moving
	
	return
	
func _physics_process(delta):
	if current_id_path.is_empty():
		return
	if startMoving == false:
		return
		
	target_position = tile_map.map_to_local(current_id_path.front())
	person_node.global_position = person_node.global_position.move_toward(target_position, 3)
	
	if person_node.global_position == target_position:
		current_id_path.pop_front()
		startMoving == false
		emit_signal("finishedMoving")
	return
	
func _spawnPlayers():
	pass
	
func _spawnEnemies():
	pass

func _loadBackground():
	pass

func _startMusic():
	pass
