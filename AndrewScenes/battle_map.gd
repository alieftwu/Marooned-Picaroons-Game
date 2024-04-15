extends Node2D

@onready var tile_map = $TileMap
@onready var main_camera = $BattleCam
@onready var player = $Player

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

var height : int = 8
var width : int = 8
var hazardPlaced : bool = false
var random_ColNum : int
var random_ExtraColNum : int
var random_SafeRowNum : int
var random_DangerRowNum : int

# tile source IDs
var stoneTile_source_id : int = 5
var rockStoneTile_source_id : int = 6

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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _generateMap():
	tile_map.clear()
	random_SafeRowNum = randi_range(0, height - 1)
	random_DangerRowNum = randi_range(0, height - 1)
	for y in range(height):
		random_ColNum = randi_range(1, width - 2)
		random_ExtraColNum = randi_range(1, width - 2)
		for x in range(width):
			if x == random_ColNum and y != random_SafeRowNum:
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				tile_map.set_cell(0, Vector2i(x, y), rockStoneTile_source_id, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), stoneTile_source_id, Vector2i(0, 0))
	
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
				
func get_AStarGrid() -> AStarGrid2D:
	return astar_grid
	
func get_TileMap():
	return tile_map
	
func movePerson():
	pass
func _spawnPlayers():
	pass
	
func _spawnEnemies():
	pass

func _loadBackground():
	pass

func _startMusic():
	pass
