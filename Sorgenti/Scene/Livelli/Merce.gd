extends Panel


func _process(_delta):
	var isOptionsOpen = Saving.menu_state == Saving.MENU_STATES.OPTIONS
	if Input.is_action_just_pressed("interact") and get_parent().canOpenPanel and !isOptionsOpen:
		if !visible:
			get_parent().openPannel()
		else:
			get_parent().closePannel()

