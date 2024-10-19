extends Control
#viene richiamato da player e da MonetePossedute

onready var dimentionPixelCoin = 32
var heartSize = 960
onready var configManager = get_node("/root/Config")
onready var maxLife = configManager.getProperty("player","max_life")


func _ready():
	var temp = Saving.get("lifeLevel")
	maxLife += temp*0.5
	$Hearts.rect_size.x = maxLife * heartSize

func on_player_life_changed(heart : float):
	$Hearts.rect_size.x = heart * heartSize

func move_right(numberOfDigit):
	$Hearts.rect_pivot_offset.x += dimentionPixelCoin*numberOfDigit

func updateMaxLife(life):
	$Hearts.rect_size.x = life * heartSize
	
