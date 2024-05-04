extends CharacterBody2D

@onready var around = get_node("Area2D")
@onready var bubble = get_node("TextureRect")
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D



@export var npcText = ["I say words! and when you press space, I say more!", "like this!", "Very cool I know.", "Now lets fight!"]

signal showTextBox
signal hideTextBox
signal newText

var closeEnough = false
var textDisplayed = false
var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(586.0,63.0)

func _ready():
	bubble.hide()
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _process(delta):
	if(closeEnough):
		bubble.show()
	else:
		bubble.hide()
	# check for interaction
	if Input.is_action_just_pressed("ui_accept") and closeEnough and !textDisplayed:
		textDisplayed = true
		print("output text: ", npcText, " goes here!")
		emit_signal("showTextBox")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body != self and body != get_parent().get_node("TileMap"):
		print("display and await!")
		closeEnough = true
		emit_signal("newText")


func _on_area_2d_body_exited(body):
	print("remove textbox")
	closeEnough = false
	textDisplayed = false
	emit_signal("hideTextBox")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
