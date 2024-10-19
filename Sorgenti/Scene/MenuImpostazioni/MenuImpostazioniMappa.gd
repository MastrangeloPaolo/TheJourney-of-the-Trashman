extends Control


var isPause : bool = false

func showMenu():
	focus()
	if isPause == false:
		self.visible = true
		get_tree().paused = true
		isPause = true
	elif isPause == true:
		get_tree().paused = false
		self.visible = false
		isPause = false


func _on_Quit_pressed():
	get_tree().paused = false
	if get_parent().get_parent().get_parent().name.find("Mercante") != -1:
		SceneManager.goto_scene("res://Scene/Game.tscn")
	else: 
		SceneManager.goto_scene("res://Scene/MenuPrincipale/MenuPrincipale.tscn")

func _on_Resume_pressed():
	get_parent().viewMenu()


func _on_Settings_pressed():
	get_parent().showOptions()

func focus():
	$Panel/VBoxContainer/Settings.grab_focus()
