extends Control

onready var configManager = get_node("/root/Config")

onready var durationTimerRevivePaper = configManager.getProperty("paper_enemy","duration_timer_revive")
onready var damagePaper = configManager.getProperty("paper_enemy","damage")
onready var speedPaper = configManager.getProperty("paper_enemy","speed")

onready var speedPlasic = configManager.getProperty("plastic_enemy","speed")
onready var durationTimerRevivePlasic = configManager.getProperty("plastic_enemy","duration_timer_revive")
onready var damagePlastic = configManager.getProperty("plastic_enemy","damage")

onready var speedGlass = configManager.getProperty("glass_enemy","speed")
onready var durationTimerReviveGlass = configManager.getProperty("glass_enemy","duration_timer_revive")
onready var damageGlass = configManager.getProperty("glass_enemy","damage")
onready var bulletSpeed = configManager.getProperty("glass_enemy","bullet_speed")
onready var bulletDuration = configManager.getProperty("glass_enemy","bullet_duration")
onready var bulletDamage = configManager.getProperty("glass_enemy","bullet_damage")
onready var bounceNumber = configManager.getProperty("glass_enemy","bullet_bounce_number")


var speed
var duration_timer_revive
var damage
var bulletS
var bulletD
var bulletDam
var bounce

signal changeDifficultyPaper
signal changeDifficultyPlastic
signal changeDifficultyGlass

func _ready():
	if isInLevel():
		for child in get_node("../../../../../").get_children():
			if child.name.to_lower().find("ncarta") != -1:
				if connect("changeDifficultyPaper",  get_node("../../../../../" + child.name), "isChangeDifficulty"): print("ERR CONN con NC")
			elif child.name.to_lower().find("nplastica") != -1:
				if connect("changeDifficultyPlastic",  get_node("../../../../../" + child.name), "isChangeDifficulty"): print("ERR CONN con NP")
			elif child.name.to_lower().find("nvetro") != -1:
				if connect("changeDifficultyGlass",  get_node("../../../../../" + child.name), "isChangeDifficulty"): print("ERR CONN con NV")
		var difLevel = Saving.get("difficulty")
		setPaper(difLevel)
		setPlastic(difLevel)
		setGlass(difLevel)

# input: da 0 a 2 
func setDifficulty(index):
	Saving.set("difficulty",index)
	Saving.saveGame()
	if isInLevel():
		setPaper(index)
		setPlastic(index)
		setGlass(index)

func isInLevel():
	var flag = false
	if get_node("../../../../").name != "root":
		if get_node("../../../../../").name.to_lower().find("livello") != -1:
			flag = true
	return flag



func setPaper(index):
	if index == 0:
		duration_timer_revive = durationTimerRevivePaper + 2
		damage = damagePaper
		speed = speedPaper - 20
	elif index == 1:
		duration_timer_revive = durationTimerRevivePaper
		damage = damagePaper
		speed = speedPaper
	else:
		duration_timer_revive = durationTimerRevivePaper -2
		damage = damagePaper +0.5
		speed = speedPaper +20
	emit_signal("changeDifficultyPaper",duration_timer_revive,damage,speed)
	
func setPlastic(index):
	if index == 0:
		speed = speedPlasic -20
		duration_timer_revive = durationTimerRevivePlasic +2
		damage = damagePlastic
	elif index == 1:
		speed = speedPlasic 
		duration_timer_revive = durationTimerRevivePlasic
		damage = damagePlastic
	else:
		speed = speedPlasic +20
		duration_timer_revive = durationTimerRevivePlasic -2
		damage = damagePlastic +0.5
	Saving.set("plastic_damage",damage)
	emit_signal("changeDifficultyPlastic",duration_timer_revive,damage,speed)



func setGlass(index):
	if index == 0:
		speed = speedGlass -20
		duration_timer_revive = durationTimerReviveGlass +2
		damage = damageGlass
		bulletS = bulletSpeed -50
		bulletD = bulletDuration -0.5
		bulletDam = bulletDamage
		bounce = bounceNumber
	elif index == 1:
		speed = speedGlass
		duration_timer_revive = durationTimerReviveGlass
		damage = damageGlass
		bulletS = bulletSpeed
		bulletD = bulletDuration
		bulletDam = bulletDamage
		bounce = bounceNumber
	else:
		speed = speedGlass
		duration_timer_revive = durationTimerReviveGlass -2
		damage = damageGlass 
		bulletS = bulletSpeed +50
		bulletD = bulletDuration +0.5
		bulletDam = bulletDamage +0.5
		bounce = bounceNumber +1
	Saving.set("bullet_damage",bulletDam)
	Saving.set("bullet_bounce_number",bounce)
	emit_signal("changeDifficultyGlass",duration_timer_revive,damage,speed,bulletS,bulletD)


