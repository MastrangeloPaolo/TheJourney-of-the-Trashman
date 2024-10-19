extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

onready var positionPlayer = get_parent().get_node("Player")

func _process(_delta):
	self.position.x = positionPlayer.position.x
	self.position.y = positionPlayer.position.y
