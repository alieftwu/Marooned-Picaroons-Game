extends TileMap

@onready var battle_map = get_parent()
@onready var tile_map = get_node("../TileMap")
@onready var turn_queue = $"../../TurnQueue"
var astar_grid: AStarGrid2D
var height : int = 9
var width : int = 9
var speed : int = 1
var starting_location
var tile_position : Vector2
var tile_data
var current_position : Vector2

# tile source IDs
var turkDot_source_id : int = 3


# Called after tile map is done generating by call_deferred
func _ready():
	await battle_map.finishedGenerating
	height = battle_map.height
	width = battle_map.width
	astar_grid = battle_map.astar_grid

func _generateMoveMap(player):
	self.clear()
	starting_location = tile_map.local_to_map(player.global_position)
	exploreGrid(starting_location[0], starting_location[1], 0, player.stats.Speed)
	self.erase_cell(0, starting_location)

func exploreGrid(x, y, moves_made, max_moves):
	current_position = Vector2(x, y)
	self.set_cell(0, current_position, turkDot_source_id, Vector2i(0, 0))
	
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
		
		tile_position = Vector2(new_x, new_y)
		tile_data = tile_map.get_cell_tile_data(0, tile_position)
	
		# Check bounds and if can go to the new cell
		if (tile_data != null) and (tile_data.get_custom_data("walkable") == true):
			exploreGrid(new_x, new_y, moves_made + 1, max_moves)
