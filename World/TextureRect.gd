extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
<<<<<<< HEAD
=======
	pass
>>>>>>> aliefs-branch


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
<<<<<<< HEAD
=======

func _on_npc_show_text_box():
	print("show TB\n", get_parent().get_parent().name)
	show()

func _on_npc_hide_text_box():
	print("hide TB\n", get_parent().get_parent().name)
	hide()

func _on_label_hide_box_label():
	print("hide TB label\n", get_parent().get_parent().name)
	hide()
>>>>>>> aliefs-branch
