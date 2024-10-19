extends Camera2D


onready var positionPlayer = get_parent().get_node("Player")

var deathLine = false

func _process(_delta):
	if !deathLine:
		position.x = positionPlayer.position.x
		position.y = positionPlayer.position.y -100

#connessa a player da player
func blockCamera():
	deathLine = true
	
