extends PopupPanel

var action

func _input(event):
	if(visible && event is InputEventKey):
		Settings.emptyPrev(action,event)
		Settings.setKey(action,event)
		Settings.saveKeys()
		get_parent().reloadTexts()
		self.hide()


func setAction(new_action):
	self.action = new_action
