extends PathFollow2D

@onready var NPC = get_node("PatrollingGuard")

var right = true
var animName = "walk_"
var canMove = true

# Called when the node enters the scene tree for the first time.
func _ready():
	progress = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if canMove:
		if right:
			NPC.direction = "right"
			animName += NPC.direction
			progress += 1
			if progress_ratio == 1:
				right = false
		else:
			NPC.direction = "left"
			animName += NPC.direction
			progress -= 1
			if progress_ratio == 0:
				right = true
	#NPC.get_node("PlayerAnimation").play(animName)
	pass


func _on_halt_move():
	canMove = false
	pass # Replace with function body.


func _on_patrolling_guard_halt_move():
	canMove = false
	pass # Replace with function body.
