extends Node2D

class_name BattleMap

@onready var turn_queue = $"../TurnQueue"
@onready var tile_map = $TileMap
@onready var main_camera = $BattleCam
@onready var highlight_map = $HighlightMap
@onready var background = $Background
@onready var abilityControl = $AbilityControl
@onready var cooldownDisp0 = $Ability1/cooldown
@onready var cooldownDisp1 = $Ability2/cooldown
@onready var cooldownDisp2 = $Ability3/cooldown
@onready var cooldownDisp3 = $Ability4/cooldown
@onready var button2 = $Ability2
@onready var button3 = $Ability3
@onready var button4 = $Ability4
@onready var abilityMusic = $abilityMusic
@onready var damageDisplay = $DamageDisplay
@onready var abilityInfo = $AbilityInfo
@onready var abilityInfoLabel = $AbilityInfo/InfoText
@export var mapType : String

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
var prisonSpikeSwitch : bool = false # to switch what spikes are spawned for damage animation
var infiniteMoveCount : int = 0

# Unit Storage
var friendlyUnits : Array
var Units : Array
var enemyUnits : Array
var currentPlayer : Node2D #Not being used everywhere is should
var currentEnemy : Node2D

# tile source IDs
var grass_tile_source_id : int = 0
var grass_list : Array = [Vector2i(2,1), Vector2i(3,1), Vector2i(1,2), Vector2i(2,2), Vector2i(3,3),
Vector2i(1,3), Vector2i(7,1), Vector2i(3,4), Vector2i(1,3)]
var snow_tiles : int = 1
var snowTiles_list : Array = [Vector2i(5,9), Vector2i(11,9), Vector2i(5,8), Vector2i(11,9), Vector2i(11,9), Vector2i(11,9),
Vector2i(11, 9), Vector2i(11,9), Vector2i(8,5), Vector2i(10,9), Vector2i(11,9), Vector2i(11,9)]
var sewer_tiles : int = 2
var sewer_coords = Vector2i(8,8)
var prison_tiles : int = 3
var prison_coord = Vector2i(5,1)
var prisionHole_coord = Vector2i(4,10)
var prisionSpike_coord = Vector2i(4,9)
var castle_tiles : int = 4
var castleTiles_list : Array = [Vector2i(32, 68), Vector2i(33,69), Vector2i(35,68), Vector2i(36, 71),
Vector2i(39,71), Vector2i(36,72), Vector2i(37,73)]
# var castleBossTiles_list : Array = [Vector2i(29, 70)]
var brownPrison_coors = Vector2i(27,72)
var grassBush_tile : int = 5
var grassRock : int = 6
var grassTrunk : int = 7
var sewerBarrel : int = 8
var BarrelOnStone_source_id : int = 9
var CrateOnStone_source_id : int = 10
var stonePath_source_id : int = 11
var StoneBasic_atlas = Vector2i(0,0)
var sewerBrokenBarrel_tile : int = 12
var sewerBrokenCrate_tile : int = 13
var sewerCrate_tile : int = 14
var castleHoles_tile : int = 15
var castleBossSpikes_tile : int = 16
var castleSpikes_tile : int = 17
var castleBossHoles : int = 18
var stonesCastle_tile : int = 19
var snowTrunk_tile : int = 20
var woodPlank_tile : int = 24
var woodPlankBarrel_tile : int = 25
var woodPlankCrate_tile : int = 26

signal moveSelected
signal finishedMoving
signal characterMovementComplete
signal finishedGenerating
signal attackChosen
signal attackDone
signal abilityFinished

# Called when the node enters the scene tree for the first time.
func initialize():
	if mapType == null:
		print("maptype is null")
	print(mapType)
	print("test")
	randomize()
	main_camera.make_current()
	gatherUnitInfo()
	if (mapType == "City"):
		{
			0: _generateCityMap()
		}
	if (mapType == "Prison"):
		{
			0: _generatePrisonMap()
		}
	if (mapType == "Grass"):
		{
			0: _generateGrassMap()
		}
	if (mapType == "Snow"):
		{
			0: _generateSnowMap()
		}
	if (mapType == "Sewer"):
		{
			0: _generateSewerMap()
		}
	if (mapType == "Castle"):
		{
			0: _generateCastleMap()
		}
	if (mapType == "Ship"):
		{
			0: _generateShipMap(),
		}
	if (mapType == "CastleTown"):
		{
			0: _generateCastleTownMap(),
		}
	if (mapType == "FirstVillage"):
		{
			0: _generateFirstVillageMap()
		}
	if (mapType == "CountyPrison"):
		{
			0: _generateCountyPrisonMap()
		}
	if (mapType == "FrontGate"):
		{
			0: _generateFrontGateMap()
		}
	if (mapType == "BossCastle"):
		{
			0: _generateBossCastleMap()
		}
	if (mapType == "CastleCityInside"):
		{
			0: _generateCastleCityInsideMap()
		}
	
	_makeAStarGrid()
	canMove = false
	emit_signal("finishedGenerating")
	
	return
	
func _generateCityMap():
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
				
	var newBackImage = load("res://Combat/Resources/firstVillageBackground2.png")
	loadBackground(newBackImage)			
	return
	
func _generateBossCastleMap():
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
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), castle_tiles, castleTiles_list.pick_random())

	prisonSpikeSwitch = false			
	var newBackImage = load("res://Combat/Resources/bossBackground1.png")
	loadBackground(newBackImage)			
	return
	
func _generateFrontGateMap():
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
				
	var newBackImage = load("res://Combat/Resources/Front Gate Background.png")
	loadBackground(newBackImage)			
	return
	
func _generateCountyPrisonMap(): 
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
				
	var newBackImage = load("res://Combat/Resources/CountyPrisonBackground.png")
	loadBackground(newBackImage)			
	return
	
func _generateFirstVillageMap():
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
				
	var newBackImage = load("res://Combat/Resources/firstvillagebackground.png")
	loadBackground(newBackImage)			
	return
	
func _generateCastleTownMap():
	
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
				
	var newBackImage = load("res://Combat/Resources/castleTownBackground.png")
	loadBackground(newBackImage)			
	return
	
func _generateCastleCityInsideMap():
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
				
	var newBackImage = load("res://Combat/Resources/castleCityBackground.png")
	loadBackground(newBackImage)			
	return
	
func _generateShipMap():
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
					tile_map.set_cell(0, Vector2i(x, y), woodPlankBarrel_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankCrate_tile, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankCrate_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankBarrel_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankBarrel_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankCrate_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankCrate_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), woodPlankBarrel_tile, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), woodPlank_tile, Vector2i(0,0))
				
	var newBackImage = load("res://Combat/Resources/shipBackground.png")
	loadBackground(newBackImage)			
	return
	
func _generatePrisonMap():
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
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
				else:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
				else:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
				else:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
				else:
					tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prisionHole_coord)
			else:
				tile_map.set_cell(0, Vector2i(x, y), prison_tiles, prison_coord)
				
	prisonSpikeSwitch = true			
	var newBackImage = load("res://Combat/Resources/prisonBackground.png")
	loadBackground(newBackImage)			
	return	
	
func _generateGrassMap():
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
					tile_map.set_cell(0, Vector2i(x, y), grassBush_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), grassTrunk, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), grassBush_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), grassRock, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), grassBush_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), grassTrunk, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), grassBush_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), grassRock, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), grass_tile_source_id, grass_list.pick_random())	
				
	var newBackImage = load("res://Combat/Resources/forestBackground1.png")
	loadBackground(newBackImage)					
	return
	
func _generateSnowMap():
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
					tile_map.set_cell(0, Vector2i(x, y), snowTrunk_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), snow_tiles, Vector2i(11, 6))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), snowTrunk_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), snow_tiles, Vector2i(11, 6))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), snowTrunk_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), snow_tiles, Vector2i(11, 6))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), snowTrunk_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), snow_tiles, Vector2i(11, 6))
			else:
				tile_map.set_cell(0, Vector2i(x, y), snow_tiles, snowTiles_list.pick_random())	
				
	var newBackImage = load("res://Combat/Resources/SnowBackground3.png")
	loadBackground(newBackImage)					
	return	
	
func _generateSewerMap():
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
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenBarrel_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenCrate_tile, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), sewerBarrel, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), sewerCrate_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenCrate_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenBarrel_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.5:
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenCrate_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), sewerBrokenBarrel_tile, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), sewer_tiles, sewer_coords)
				
	var newBackImage = load("res://Combat/Resources/sewerBackground1.png")
	loadBackground(newBackImage)			
	return
	
func _generateCastleMap():
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
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum != random_SafeRowNum and y == random_DangerRowNum and x == random_ExtraColNum:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			elif random_DangerRowNum2 != random_SafeRowNum and y == random_DangerRowNum2 and x == random_ExtraColNum3:
				if randf() < 0.75:
					tile_map.set_cell(0, Vector2i(x, y), castleHoles_tile, Vector2i(0, 0))
				else:
					tile_map.set_cell(0, Vector2i(x, y), stonesCastle_tile, Vector2i(0, 0))
			else:
				tile_map.set_cell(0, Vector2i(x, y), castle_tiles, castleTiles_list.pick_random())
			
	prisonSpikeSwitch = false			
	var newBackImage = load("res://Combat/Resources/CastleBackground1.png")
	loadBackground(newBackImage)			
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
	var tile_data = tile_map.get_cell_tile_data(0, current_position)
	if (tile_data.get_custom_data("sticky") == false) or (moves_made == 0):
	
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
			tile_data = tile_map.get_cell_tile_data(0, tile_position)
		
			# Check bounds and if can go to the new cell
			if (tile_data != null) and (tile_data.get_custom_data("walkable") == true):
				var global_tile_pos = tile_map.map_to_local(tile_position)
				var noUnitThere = true
				for unit in Units:
					if unit.global_position == global_tile_pos:
						noUnitThere = false
						break
				if (noUnitThere == true):
					getAllowedSpaces(new_x, new_y, max_moves, moves_made + 1, spacesArray)
			
	return
	
func movePerson(player):
	currentPlayer = player
	current_id_path.clear()
	# print("child ", player.get_index(), " waiting to pick")
	highlight_map._generateMoveMap(currentPlayer)
	
	var starting_position = tile_map.local_to_map(currentPlayer.global_position)
	var allowedSpaces : Array = []
	getAllowedSpaces(starting_position[0], starting_position[1], currentPlayer.speed, 0, allowedSpaces)
	await highlight_map.highlightPlayer(player)
	
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
	checkHazardTile(player)
	emit_signal("characterMovementComplete")
	return
	
func _physics_process(_delta):
	if current_id_path.is_empty():
		return
	if startMoving == false:
		return

	infiniteMoveCount += 1
	if infiniteMoveCount >= 60:
		infiniteMoveCount = 0
		print("Move error")
		emit_signal("finishedMoving")
	if current_id_path.is_empty() == false:
		target_position = tile_map.map_to_local(current_id_path.front())
	var activeUnit = turn_queue.get_active_character()
	activeUnit.global_position = activeUnit.global_position.move_toward(target_position, 3)
	
	if (activeUnit.global_position == target_position) or (current_id_path.is_empty()):
		if current_id_path.is_empty() == false:
			current_id_path.pop_front()
		if current_id_path.is_empty():
			startMoving = false
			infiniteMoveCount = 0
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
				abilityControl.checkBlocking(unit)
				var attackModifier = abilityControl.checkPassiveAttack(player, 0, "Melee")
				var defendModifier = abilityControl.checkPassiveDefend(unit, 0, "Melee")
				var damage = (currentPlayer.basicAttackDamage * attackModifier * defendModifier) - unit.armor
				damage = snappedf(damage, 0.01)
				if damage < 0:
					damage = 0
				unit.health -= damage
				unit.updateHealthBar()
				var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
				abilityMusic.stream = testMusic
				abilityMusic.play()
				await updateDamageDisplay(unit, damage)
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
				abilityControl.checkBlocking(unit)
				var attackModifier = abilityControl.checkPassiveAttack(player, 0, "Melee")
				var defendModifier = abilityControl.checkPassiveDefend(unit, 0, "Melee")
				var damage = (currentPlayer.basicAttackDamage * attackModifier * defendModifier) - unit.armor
				damage = snappedf(damage, 0.01)
				if damage < 0:
					damage = 0
				unit.health -= damage
				unit.updateHealthBar()
				var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
				abilityMusic.stream = testMusic
				abilityMusic.play()
				await updateDamageDisplay(unit, damage)
				print("hit enemy!")
				break
		
	canAttack = false
	highlight_map.clear()
	emit_signal("attackDone")
	
	return
	
func moveEnemyPerson(enemy): # move enemy randomly
	print("move")
	currentEnemy = enemy
	var enemy_position = currentEnemy.global_position
	var allowedSpaces : Array = []
	var starting_position = tile_map.local_to_map(enemy_position)
	await getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	var attemptCounter = 0 #if we don't find a good random move in this many tries we just dont move
	var random_movePick
	#print("Moves: ", allowedSpaces)
	if allowedSpaces.is_empty() == false:
		if len(allowedSpaces) != 1:
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
				startMoving = false
				emit_signal("finishedMoving")
		else:
			startMoving = false
			emit_signal("finishedMoving")
	else:
		startMoving = false
		emit_signal("finishedMoving")
	
	startMoving = false
	await update_AStarGrid()
	await checkHazardTile(enemy)
	emit_signal("characterMovementComplete")
	return
		
func agressiveEnemyMove(enemy): # move enemy to nearest player
	print("agressive move")
	currentEnemy = enemy
	var enemy_position = currentEnemy.global_position
	var allowedSpaces : Array = []
	var starting_position = tile_map.local_to_map(enemy_position)
	await getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	var smallestDistance = 999999
	var move_pick = Vector2(0,0)
	#print("agressMoves: ", allowedSpaces)
	if allowedSpaces.is_empty() == false:
		if len(allowedSpaces) != 1:
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
			current_id_path = astar_grid.get_id_path(
			starting_position,
			move_pick	
			).slice(1)
			print("path: ", current_id_path)
			startMoving = true
			await finishedMoving # wait for physics to finish moving
		else:
			startMoving = false
			emit_signal("finishedMoving")
	else:
		startMoving = false
		emit_signal("finishedMoving")
	
	startMoving = false
	await update_AStarGrid()
	await checkHazardTile(enemy)
	emit_signal("characterMovementComplete")
	return
	
func cowardEnemyMove(enemy): # move enemy away from nearest player
	print("coward move")
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
	
	await getAllowedSpaces(starting_position[0], starting_position[1], currentEnemy.speed, 0, allowedSpaces)
	var validMove = false
	
	var largestDistance = -999999
	var move_pick
	#print("ScaredMovses: ", allowedSpaces)
	if (allowedSpaces.is_empty() == false) and (closestPlayer != null):
		if len(allowedSpaces) != 1:
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
			current_id_path = astar_grid.get_id_path(
			starting_position,
			move_pick	
			).slice(1)
			print("path: ", current_id_path)
			startMoving = true
			await finishedMoving # wait for physics to finish moving
		else:
			startMoving = false
			emit_signal("finishedMoving")
	else:
		startMoving = false
		emit_signal("finishedMoving")
	
	startMoving = false
	await update_AStarGrid()
	await checkHazardTile(enemy)
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
		var attacked_unit = random_Choice[1] # get the unit being attacked
		await abilityControl.checkFlags(attacked_unit)
		await abilityControl.checkBlocking(attacked_unit)
		var attackModifier = abilityControl.checkPassiveAttack(enemy, 0, "Melee")
		var defendModifier = abilityControl.checkPassiveDefend(attacked_unit, 0, "Melee")
		var damage = (currentEnemy.basicAttackDamage * attackModifier * defendModifier) - attacked_unit.armor
		damage = snappedf(damage, 0.01)
		if damage < 0:
			damage = 0
		attacked_unit.health -= damage
		await attacked_unit.updateHealthBar()
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
		await updateDamageDisplay(attacked_unit, damage)
		print("player hit!")
	else:
		print("no player found")
		
	emit_signal("attackDone")
	
	return
	
func gatherUnitInfo():
	friendlyUnits = get_tree().get_nodes_in_group("PlayerUnits")
	Units = get_tree().get_nodes_in_group("Units")
	enemyUnits = get_tree().get_nodes_in_group("EnemyUnits")
	pass

func checkHazardTile(unit):
	var player_position : Vector2i = tile_map.local_to_map(unit.global_position)
	var tile_data = tile_map.get_cell_tile_data(0, player_position)
	if (tile_data.get_custom_data("hazard") == true):
		unit.health -= 15
		var testMusic = load("res://Combat/Resources/07_human_atk_sword_2.wav")
		abilityMusic.stream = testMusic
		abilityMusic.play()
		unit.updateHealthBar()
		updateDamageDisplay(unit, 15)
		
		if prisonSpikeSwitch == false:
			tile_map.set_cell(0, player_position, castleSpikes_tile, Vector2i(0, 0))
			await get_tree().create_timer(1).timeout # wait for 3 secodns
			tile_map.set_cell(0, player_position, castleHoles_tile, Vector2i(0, 0))
		else:
			tile_map.set_cell(0, player_position, prison_tiles, prisionSpike_coord)
			await get_tree().create_timer(1).timeout # wait for 3 secodns
			tile_map.set_cell(0, player_position, prison_tiles, prisionHole_coord)
	return
	
func loadBackground(newTexture):
	background.texture = newTexture
	return

func enemyRandomAbility(enemy):
	var abilityList : Array = []
	if enemy.special1CoolDown == 0:
		if enemy.abilityList[0] != null:
			abilityList.append([1, enemy.abilityList[0]])
	if enemy.special2CoolDown == 0:
		if enemy.abilityList[1] != null:
			abilityList.append([2, enemy.abilityList[1]])
	if enemy.special3CoolDown == 0:
		if enemy.abilityList[2] != null:
			abilityList.append([3, enemy.abilityList[2]])
	print("EnemyMoves: ", abilityList)
	if abilityList.is_empty() == true:
		_on_ability_1_pressed()
	else:
		if randf() < 0.35:
			_on_ability_1_pressed()
		else:
			enemy.canPress = false
			var cooldown : int = 0
			var unitAbility = abilityList.pick_random()
			cooldown = await abilityControl.checkMoveSlot(enemy, unitAbility[1]) # execute ability
			await increaseCooldown(enemy, cooldown, unitAbility[0])
	emit_signal("abilityFinished")
	return

func _on_ability_1_pressed(): # basic attack Option
	var currentUnit = turn_queue.get_active_character()
	if currentUnit.canPress == true:
		currentUnit.canPress = false
		#print("button 1 pressed!")
		var isPlayer = abilityControl.checkTeam(currentUnit)
		if isPlayer:
			await simpleAttack(currentUnit)
		else:
			await simpleEnemyAttack(currentUnit)
		emit_signal("abilityFinished")	
	return

func _on_ability_2_pressed(): # special ability 1, gotten from unit data
	var currentUnit = turn_queue.get_active_character()
	if currentUnit.special1CoolDown == 0: # button 2 is special ability 1, check cooldown
		if currentUnit.canPress == true:
			currentUnit.canPress = false
			var cooldown : int = 0
			#print("button 2 pressed!")
			var unitAbility = currentUnit.abilityList[0]
			cooldown = await abilityControl.checkMoveSlot(currentUnit, unitAbility) # execute ability
			await increaseCooldown(currentUnit, cooldown, 1)
			emit_signal("abilityFinished")
	else:
		print("On cooldown") # play a sound after	
	return

func _on_ability_3_pressed(): # special ability 2, gotten from unit data
	var currentUnit = turn_queue.get_active_character()
	if currentUnit.special2CoolDown == 0:
		if currentUnit.canPress == true:
			currentUnit.canPress = false
			var cooldown : int = 0
			#print("button 3 pressed!")
			var unitAbility = currentUnit.abilityList[1]
			cooldown = await abilityControl.checkMoveSlot(currentUnit, unitAbility) # execute ability
			await increaseCooldown(currentUnit, cooldown, 2)
			emit_signal("abilityFinished")	
	else:
		print("On cooldown") # play a sound after	
	return

func _on_ability_4_pressed(): # special ability 3, gotten from unit data
	var currentUnit = turn_queue.get_active_character()
	if currentUnit.special3CoolDown == 0:
		if currentUnit.canPress == true:
			currentUnit.canPress = false
			var cooldown : int = 0
			#print("button 4 pressed!")
			var unitAbility = currentUnit.abilityList[2]
			cooldown = await abilityControl.checkMoveSlot(currentUnit, unitAbility) # execute ability
			await increaseCooldown(currentUnit, cooldown, 3)
			emit_signal("abilityFinished")	
	else:
		print("On cooldown") # play a sound after	
		return

func increaseCooldown(unit, cooldown, moveSlot):
	if moveSlot == 1:
		unit.special1CoolDown = cooldown
	elif moveSlot == 2:
		unit.special2CoolDown = cooldown
	elif moveSlot == 3:
		unit.special3CoolDown = cooldown
	return

func checkCooldownIcons(unit):
	cooldownDisp0.visible = false
	if unit.special1CoolDown == 0:
		cooldownDisp1.visible = false
	else:
		cooldownDisp1.visible = true
		cooldownDisp1.text = " " + str(unit.special1CoolDown)
	print(unit.special1CoolDown)
	if unit.special2CoolDown == 0:
		cooldownDisp2.visible = false
	else:
		cooldownDisp2.visible = true
		cooldownDisp2.text = " " + str(unit.special2CoolDown)
	print(unit.special1CoolDown)
	if unit.special3CoolDown == 0:
		cooldownDisp3.visible = false
	else:
		cooldownDisp3.visible = true
		cooldownDisp3.text = " " + str(unit.special3CoolDown)
	return

func setAttackIconsDull(): # make attacks dull
	cooldownDisp0.visible = true
	cooldownDisp1.visible = true
	cooldownDisp2.visible = true
	cooldownDisp3.visible = true
	cooldownDisp1.text = ""
	cooldownDisp2.text = ""
	cooldownDisp3.text = ""
	return

func checkStun(unit): # see if unit needs to skip turn
	var skipTurn = false
	if unit.isStunned == true:
		skipTurn = true
		return skipTurn

func updateDamageDisplay(player, damage):
	damageDisplay.global_position = player.global_position + Vector2(-8, -16)
	damageDisplay.visible = true
	damageDisplay.text = ("-" + str(damage) + " damage")
	await get_tree().create_timer(0.5).timeout # wait for 2 secodns
	damageDisplay.visible = false
	return

func updateDamageDisplayHeal(player, health):
	damageDisplay.global_position = player.global_position + Vector2(-8, -16)
	damageDisplay.visible = true
	damageDisplay.text = ("+" + str(health) + " health")
	await get_tree().create_timer(0.55).timeout # wait for 2 secodns
	damageDisplay.visible = false
	return
	
func updateButtons(player): # update icons to match abilities
	var button2Label = player.abilityList[0]
	var button3Label = player.abilityList[1]
	var button4Label = player.abilityList[2]
	var buttonLoad
	if button2Label == "pistolShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/23.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "heavySwordSwing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/43.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "recklessFrenzy":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/41.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "takeDown":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/49.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "pirateBlessing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/15.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "axeToss": # make daggerToss
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/48.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "quickStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/4.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "circleSlash":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/32.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "desparateStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/46.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "rapidFire":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/50.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "cannonShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/7.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "engagingBlock":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/31.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "bombThrow":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/19.png")
		button2.texture_normal = buttonLoad
	elif button2Label == "damageWave":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/22.png")
		button2.texture_normal = buttonLoad
	if button3Label == "pistolShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/23.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "heavySwordSwing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/43.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "recklessFrenzy":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/41.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "takeDown":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/49.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "pirateBlessing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/15.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "axeToss": # make daggerToss
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/48.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "quickStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/4.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "circleSlash":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/32.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "desparateStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/46.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "rapidFire":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/50.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "cannonShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/7.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "engagingBlock":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/31.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "bombThrow":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/19.png")
		button3.texture_normal = buttonLoad
	elif button3Label == "damageWave":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/22.png")
		button3.texture_normal = buttonLoad
	if button4Label == "pistolShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/23.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "heavySwordSwing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/43.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "recklessFrenzy":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/41.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "takeDown":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/49.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "pirateBlessing":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/15.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "axeToss": # make daggerToss
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/48.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "quickStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/4.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "circleSlash":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/32.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "desparateStrike":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/46.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "rapidFire":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/50.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "cannonShot":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/7.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "engagingBlock":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/31.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "bombThrow":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/19.png")
		button4.texture_normal = buttonLoad
	elif button4Label == "damageWave":
		buttonLoad = load("res://Combat/Resources/SkillIcons/PNG/22.png")
		button4.texture_normal = buttonLoad
	return

func updateAbilityInfo(player, ability):
	abilityInfo.visible = true
	abilityInfoLabel.text = getAbilityText(ability)
	return

func getAbilityText(ability):
	var text = "error"
	if ability == "Basic":
		text = "Attack a target around you for basic damage."
	elif ability == "pistolShot":
		text = "Shoot an enemy 4 or less tiles away for 200% damage."
	elif ability == "heavySwordSwing":
		text = "Attack a target next to you for 200% damage"
	elif ability == "recklessFrenzy":
		text = "Increase speed and attack of you and nearby friends at the cost of health for 2 turns."
	elif ability == "takeDown":
		text = "Must have an ally next to you, damage and stun nearby opponent for 2 turns. Ignores armor."
	elif ability == "pirateBlessing":
		text = "Partially heal any friend on the map."
	elif ability == "axeToss": # make daggerToss
		text = "Toss a dagger for 175% damage that can go over obstacles, must be 2-3 spaces away from you."
	elif ability == "quickStrike":
		text = "Attack a target around you for 120% damage, then move again."
	elif ability == "circleSlash":
		text = "Attack all targets around you for 130% basic damage."
	elif ability == "desparateStrike":
		text = "Attack a target around you, dealing 125% damage normally and 300% damage if you have less than 20 health."
	elif ability == "rapidFire":
		text = "Attack up to 2 targets 3 or less tiles away for 75% damage."
	elif ability == "cannonShot":
		text = "Attack a target in a line for 400% damage, and you are stunned for 2-3 turns. Ignores armor."
	elif ability == "engagingBlock":
		text = "Block ALL enemy damage for 1 turn, if you are not attacked before you next turn, get stunned for 2 turns."
	elif ability == "bombThrow":
		text = "Throw a bomb in a line up to 3 tiles away from you, hitting the target and all nearby units for 200% damage."
	elif ability == "damageWave":
		text = "Deal random damage to ALL enemies"
	return text

func _on_ability_1_mouse_entered(): # when mouse enters button 1
	var ability = "Basic"
	var currentPlayer = turn_queue.get_active_character()
	updateAbilityInfo(currentPlayer, ability)
	return

func _on_ability_1_mouse_exited(): # clear Infotext
	abilityInfoLabel.text = ""
	abilityInfo.visible = false
	return

func _on_ability_2_mouse_entered():
	var currentPlayer = turn_queue.get_active_character()
	var ability = currentPlayer.abilityList[0]
	updateAbilityInfo(currentPlayer, ability)
	return

func _on_ability_2_mouse_exited():
	abilityInfoLabel.text = ""
	abilityInfo.visible = false
	return

func _on_ability_3_mouse_entered():
	var currentPlayer = turn_queue.get_active_character()
	var ability = currentPlayer.abilityList[1]
	updateAbilityInfo(currentPlayer, ability)
	return

func _on_ability_3_mouse_exited():
	abilityInfoLabel.text = ""
	abilityInfo.visible = false
	return

func _on_ability_4_mouse_entered():
	var currentPlayer = turn_queue.get_active_character()
	var ability = currentPlayer.abilityList[2]
	updateAbilityInfo(currentPlayer, ability)
	return

func _on_ability_4_mouse_exited():
	abilityInfoLabel.text = ""
	abilityInfo.visible = false
	return
