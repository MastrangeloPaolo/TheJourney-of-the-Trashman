extends Control

var difficulty = 1

func _ready():
	$Difficulty/OptionButton.add_item("Easy",0)
	$Difficulty/OptionButton.add_item("Normal",1)
	$Difficulty/OptionButton.add_item("Hard",2)
	$Difficulty/OptionButton.select(difficulty)
	
	
func _process(_delta):
	if visible and Input.is_action_just_pressed("ui_accept"):
		_on_Done_pressed()


func _on_Done_pressed():
	var name =  $HBoxContainer/LineEdit.text;
	if(Saving.characterExists(name.strip_edges()) and !$Empty.visible):
		$Already.show()
		$Timer.start()
	elif(name.strip_edges().length()==0 and !$Already.visible):
		$Empty.show()
		$Timer.start()
	else:
		Saving.createPlayer(name)
		Saving.set("difficulty", difficulty)
		SceneManager.goto_scene("res://Scene/Game.tscn")
		Saving.set("isNewGame",true)


func _on_Timer_timeout():
	$Already.hide()
	$Empty.hide()


func _on_OptionButton_item_selected(index):
	difficulty = index
