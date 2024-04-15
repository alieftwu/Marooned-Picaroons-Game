extends Node2D

@onready var tile_map = $"../TileMap"
@onready var AStarGrid = get_node
@onready var BattleMap = get_parent()
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

func _ready():
	call_deferred("_post_ready")

# Called when the node enters the scene tree for the first time after ready.
func _post_ready():
	astar_grid = BattleMap.get_AStarGrid()
	tile_map = BattleMap.get_TileMap()
	
	
func _input(event):
	if event.is_action_pressed("move") == false:
		return
		
	var id_path
	astar_grid = BattleMap.get_AStarGrid()
	tile_map = BattleMap.get_TileMap()
	print(global_position)
	
	if is_moving:
		id_path = astar_grid.get_id_path(
		tile_map.local_to_map(target_position),
		tile_map.local_to_map(get_global_mouse_position())	
		)
	else:
		id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(get_global_mouse_position())	
		).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
	
func _physics_process(delta):
	if current_id_path.is_empty():
		return
	if is_moving == false:
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(target_position, 3)
	
	if global_position == target_position:
		current_id_path.pop_front()
		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else: 
			is_moving = false
			
