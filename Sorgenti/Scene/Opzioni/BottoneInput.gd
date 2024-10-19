extends Button

class_name BottoneInput

export var action: String


func _ready():
	reloadText()

func _on_BottoneInput_pressed():
	self.get_parent().changeKey(action)
	
func reloadText():
	self.text = Settings.getKey(action)
