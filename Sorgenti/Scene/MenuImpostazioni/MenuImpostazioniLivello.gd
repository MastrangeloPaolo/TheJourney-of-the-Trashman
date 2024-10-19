extends Control

onready var enemylable = $Panel/EnemyDestroy
onready var pagelable = $Panel/PageFound
onready var time = $Panel/TimePassed
onready var timer = $Timer


var totEnemy = 0
var enemyDestroy = 0

var totPage = 0
var pageFound  = 0

var isPause : bool = false

func _ready():
	timer.start()
	pagelable.text = str(pageFound) + "/" + str(totPage)
	enemylable.text = str(enemyDestroy) + "/" + str(totEnemy)

func totalalObjectRicevitor(objectName):
	if objectName.find("page") != -1: totPage +=1
	else: totEnemy += 1


		
		
#quando richiamata mosta o nasconde il menu impostazioni
func showMenu():
	focus()
	if isPause == false:
		timer.paused = true
		printPastTime()
		get_tree().paused = true
		self.visible = true
		isPause = true
	elif isPause == true:
		timer.paused = false
		get_tree().paused = false
		self.visible = false
		isPause = false

var pastTime = 0
#calcola, il tempo passato, dal tempo che manca alla fine del timer e lo fa visualizzare
func printPastTime():
	pastTime = 4096 - timer.time_left 
	
	#pastTime = stepify(pastTime, 0.01)
	
	#String.format("%.3f", culo)
	var elapedSecond = int(floor(pastTime))
	var seconds = elapedSecond%60
	var minutes = (elapedSecond/60)%60
	var decimal = (pastTime - elapedSecond) * 100
	time.text = "%02d:%02d:%02d" % [minutes, seconds, decimal]
	
# Aggiorna il numero di nemici sconfitti
func enemy_Destroy():
	enemyDestroy += 1
	enemylable.text = str(enemyDestroy) + "/" + str(totEnemy)

# Aggiorna il numero di pagine trovate
func page_Found(_id):
	pageFound += 1
	pagelable.text = str(pageFound) + "/" + str(totPage)


func _on_Quit_pressed():
	Saving.resetGame()
	Saving.menu_state = Saving.MENU_STATES.NONE
	get_tree().paused = false
	SceneManager.goto_scene("res://Scene/Game.tscn")


func _on_Resume_pressed():
	visible = false
	get_tree().paused = false
	


func _on_Settings_pressed():
	get_parent().showOptions()

func focus():
	$Panel/VBoxContainer/Settings.grab_focus()
