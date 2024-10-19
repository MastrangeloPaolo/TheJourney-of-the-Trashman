extends Button

var state = false
var red = Color(0.8, .18, 0,1)
var grey = Color(1,1,1,1)



func _pressed():
	if !get_node("../../../../").deletingCharacters:
		Saving.loadGame(self.text)
		SceneManager.goto_scene("res://Scene/Game.tscn")
	else:
		state = !state
		self.modulate = red if state else grey
