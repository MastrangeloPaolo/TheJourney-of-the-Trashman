extends Control

var deletingCharacters = false


func _input(event):
	if($BackButton.visible and event is InputEventKey and event.scancode == 16777217):
		if($Popup.visible):
			Settings.resetKeys()
			$Popup/Opzioni/ModificaComandi.reloadTexts()
		go_back()
	

func _ready():
	if(Saving.getCharacters().size() == 0):
		$MainMenu/MainMenu/Continue.disabled = true
		$MainMenu/MainMenu/New.grab_focus()
	else:
		$MainMenu/MainMenu/Continue.grab_focus()


func _on_New_pressed():
	$NewCharacter.visible = true;
	$NewCharacter/HBoxContainer/LineEdit.grab_focus()
	$MainMenu.visible = false;
	$BackButton.show()


func _on_Options_pressed():
	$Popup.show()
	$MainMenu.visible = false;
	$BackButton.show()
	$Popup/Opzioni/Volume/HSlider.grab_focus()

func _on_Quit_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	setNames()

	$Continue.visible = true;
	$Continue/ScrollContainer/Characters.get_child(0).grab_focus()
	$Continue/DeleteSaves.show()
	$MainMenu.visible = false;
	$BackButton.show()
	


func go_back():
	$NewCharacter.hide()
	$Continue.hide()
	$Popup.hide()
	$BackButton.hide()
	$MainMenu.get_child(0).grab_focus()
	$MainMenu.show()
	$Continue/DeleteSaves.hide()
	_ready()

	
func setNames():
	var character_button = preload("res://Scene/MenuPrincipale/PulsanteGiocatore.tscn")
	for character in $Continue/ScrollContainer/Characters.get_children():
		$Continue/ScrollContainer/Characters.remove_child(character)
	for character in Saving.getCharacters():
		var button = character_button.instance()
		button.text = character
		$Continue/ScrollContainer/Characters.add_child(button)
	


func _on_BackButton_button_down():
	if($Popup.visible):
		Settings.resetKeys()
		$Popup/Opzioni/ModificaComandi.reloadTexts()
	go_back()


func _on_DeleteSaves_pressed():
	if $Continue/DeleteSaves.text == "Delete saves":
		$Continue/Apply.show()
		$Continue/DeleteSaves.text = "Go back"
	else:
		$Continue/Apply.hide()
		$Continue/DeleteSaves.text = "Delete saves"
		setNames()

	deletingCharacters = !deletingCharacters


func _on_Apply_pressed():
	var c1 = []
	var grey = Color(1,1,1,1)
	for character in $Continue/ScrollContainer/Characters.get_children():
		if(character.modulate == grey):
			c1.append(character.text)
	var c2 = []
	for character in Saving.getCharacters():
		if !c1.has(character):
			c2.append(character)
	Saving.deleteCharacters(c2)
	_on_DeleteSaves_pressed()
