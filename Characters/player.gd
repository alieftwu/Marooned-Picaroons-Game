extends CharacterBody2D
class_name Player

@export var speed : float = 100.0

@onready var footsteps = $Footsteps
@onready var animation_tree : AnimationTree = $AnimationTree
var direction : Vector2 = Vector2.ZERO
var canMove = true


func _ready():
	animation_tree.active = true

func _process(delta):
	update_animation_parameters()
	
func _physics_process(delta):
#Move in 4 directions
	if canMove:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
		if direction:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()


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

func _on_halt_move():
	canMove = false
	update_animation_parameters()

func _play_footstep_audio():
	footsteps.pitch_scale = randf_range(.8, 1.2)
	footsteps.play()


func _on_res_move():
	canMove = true
