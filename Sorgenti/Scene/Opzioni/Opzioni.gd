extends Control

var idx = AudioServer.get_bus_index("Master")


func _ready():
	var _volume = Settings.getProp("volume")
	var fullscreen = Settings.getProp("fullscreen")
	$Volume/HSlider.value = int((AudioServer.get_bus_volume_db(idx)+19)/2.5)
	$Fullscreen/CheckBox.pressed = fullscreen
	if(get_parent().get_parent().name=="Menu"):
		$Difficulty.hide()
	else:
		var difficulty = Saving.get("difficulty")
		$Difficulty/OptionButton.add_item("Easy",0)
		$Difficulty/OptionButton.add_item("Normal",1)
		$Difficulty/OptionButton.add_item("Hard",2)
		$Difficulty/OptionButton.select(difficulty)


func _on_HSlider_value_changed(value):
	var volume = -80 if value==0 else value*2.5-19

	AudioServer.set_bus_volume_db(idx,volume)
	Settings.setProp("volume",volume)
	Settings.saveProps()


func _on_CheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Settings.setProp("fullscreen",OS.window_fullscreen)
	Settings.saveProps()


func _on_OptionButton_item_selected(index):
	$Difficult.setDifficulty(index)
	
