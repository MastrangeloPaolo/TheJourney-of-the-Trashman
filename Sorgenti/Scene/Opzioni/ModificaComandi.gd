extends Control

var actions = []
var keys = {}

func _ready():
	for child in get_children():
		if child is BottoneInput:
			actions.append(child.action)

func changeKey(action):
	$PopupPanel.setAction(action)
	$PopupPanel.popup()

func reloadTexts():
	for child in get_children():
		if child is BottoneInput:
			child.reloadText()

func _on_Reset_pressed():
	Settings.resetKeys()
	reloadTexts()

			
