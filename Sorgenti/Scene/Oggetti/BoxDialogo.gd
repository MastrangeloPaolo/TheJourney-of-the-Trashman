extends Control

export var event1 : String = ""
export var event2 : String = ""

onready var player = get_node("../Player")
var position
var playerPosition

var action1
var action2
var temp

func _ready():
	visible = false
	if event1 != "": 
		action1 = Settings.getKey(event1)
		$Panel/Label.text = $Panel/Label.text.replace("%1", action1)
	if event2 != "":
		action2 = Settings.getKey(event2)
		$Panel/Label.text = $Panel/Label.text.replace("%2", action2)
	

func _process(_delta):
	
	position = int(rect_position.x)
	playerPosition = int(player.position.x)
	if position-100 < playerPosition and playerPosition < position+100:
		upgreadtext()
		visible = true
	else: visible = false


func upgreadtext():
	if event1 != "": 
		temp = Settings.getKey(event1)
		if temp != action1:
			$Panel/Label.text = $Panel/Label.text.replace(action1, temp)
			action1 = temp
	if event2 != "":
		temp = Settings.getKey(event2)
		if temp != action2:
			$Panel/Label.text = $Panel/Label.text.replace(action2, temp)
			action2 = temp
