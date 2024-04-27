extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_npc_show_text_box():
	show()

func _on_npc_hide_text_box():
	hide()

func _on_label_hide_box_label():
	hide()
