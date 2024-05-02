extends CharacterBody2D
class_name Companion
@onready var animation_tree : AnimationTree = $AnimationTree

var target : Player
@export var SPEED : float  = 100.0
var initial_position : Vector2
var direction : Vector2 = Vector2.ZERO
func _ready():
	animation_tree.active = true
	var player_node = find_player_node(get_tree().get_root())
	if player_node:
		target = player_node
	else:
		print("Player node not found in the scene.")
	initial_position = global_position
func _physics_process(delta):
	
	_calculate_velocity()
	move_and_slide()
	update_animation_parameters()
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
func _calculate_velocity():
	var distanceToTarget = 20
	var pirateNumber = int(name.replace("Pirate", ""))
	var pirateMultiplicator = 1 if pirateNumber == 0 else pirateNumber
	var targetPosition = target.position - Vector2(0,-9)
	
	if position.distance_to(targetPosition) > distanceToTarget * pirateMultiplicator:
		direction = (targetPosition - position).normalized()
		velocity = direction * SPEED
		velocity.y *= 1
	elif position.y - targetPosition.y < -2 || position.y - targetPosition.y > 2:
		velocity.x = 0
	else: velocity = Vector2.ZERO

func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	if(direction != Vector2.ZERO):
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
		
func find_player_node(node):
	if node is Player:
		return node
	for child in node.get_children():
		var result = find_player_node(child)
		if result:
			return result
	return null
	
#Function to save the companion's position
func save_position():
	initial_position = global_position
#Function to restore the companion's position
func restore_position():
	global_position = initial_position
