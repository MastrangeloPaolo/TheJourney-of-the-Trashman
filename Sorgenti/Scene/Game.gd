extends Node2D

onready var animation = $AnimationPlayer
onready var sprite = $PlayerMan
onready var configManager = get_node("/root/Config")
onready var scaleSeller = configManager.getProperty("player","scaleForLevelSeller")
export onready var levelPosition = Saving.get("currentLevelPosition")
#current level è la coordinata [x,y] del livello
export onready var actualLevel = Saving.get("currentLevel")
var token = true
var animationString = ""
var level

var left
var right
var up
var down
var select

var listLevel = ["LivelloTutorial","Livello1","Livello2"]
var eventPause
func _ready():
	# PAOLO LEGGI QUI!
	# if Saving.get("isNewGame",true): faiPartireAnimazioneStrafiga()
	if Saving.get("newGame"):
		$Inizio.startDialog()
	else:
		$Inizio.free()
	setGrayZone()
	setHiddenTrash()
	if Saving.get("currentLevelName") == "Mercante": sprite.scale = Vector2(scaleSeller,scaleSeller)
	sprite.position.x = levelPosition[0]
	sprite.position.y = levelPosition[1]

	

	
# la mappa si può immaginare come un asse cartesiano, dato che ogni livello può avere massimo 4 vicini, 
# il collegamento tra i livelli (se esiste) è dato dal nome dell'animazione: 
# ess. (0;0);(1;0) collega il livello 0 al livello 1
#quando si sposta crea una stringa concatenando la coordinata del punto di partenza e del punto d'arrivo
func _process(_delta):

	left = Input.is_action_just_pressed("move_left")
	right = Input.is_action_just_pressed("move_right")
	up = Input.is_action_just_pressed("jump")
	down = Input.is_action_just_pressed("down")
	select = Input.is_action_just_pressed("ui_accept") && Saving.menu_state == Saving.MENU_STATES.NONE
	
	if token: 
		animation.play("idle",-1, 0.8)
		if right: 
			animationString = "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]) + ")" + "-" + "(" + str(actualLevel[0]+1) + ";" + str(actualLevel[1]) + ")"
			if animation.has_animation(animationString):
				if levelblock():
					actualLevel[0] += 1
					animation.play(animationString)
					sprite.flip_h = true
				else: $ScrittaBlocco.play("ApparizioneScrittaBlocco",-1,0.8)
				token = false
		elif left:
			animationString = "(" + str(actualLevel[0]-1) + ";" + str(actualLevel[1]) + ")" + "-" + "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]) + ")"
			if animation.has_animation(animationString):
				actualLevel[0] -= 1
				animation.play_backwards(animationString)
				sprite.flip_h = false
				token = false
		elif up: 
			animationString = "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]) + ")" + "-" + "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]+1) + ")"
			if animation.has_animation(animationString):
				if levelblock():
					actualLevel[1] += 1
					animation.play(animationString)
					sprite.flip_h = false
				else: $ScrittaBlocco.play("ApparizioneScrittaBlocco",-1,0.8)
				token = false
		elif down: 
			animationString = "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]-1) + ")" + "-" + "(" + str(actualLevel[0]) + ";" + str(actualLevel[1]) + ")"
			if animation.has_animation(animationString):
				actualLevel[1] -= 1
				animation.play_backwards(animationString)
				sprite.flip_h = true
				token = false
		if select:
			associatePositionNameLevel()
			if actualLevel[0] == 0 and actualLevel[1] == 0:
				savingCoordinate(level,"res://Scene/Livelli/Tutorial/LivelloTutorial.tscn")
			elif actualLevel[0] == 1 and actualLevel[1] == 0:
				savingCoordinate(level,"res://Scene/Livelli/Livello1.tscn")
			elif actualLevel[0] == 0 and actualLevel[1] == 1:
				savingCoordinate(level,"res://Scene/Livelli/Mercante.tscn")
			elif actualLevel[0] == 2 and actualLevel[1] == 0:
				savingCoordinate(level,"res://Scene/Livelli/Livello2.tscn")
				
#list in posizione 6 contiene il booleano che indica se il livello è stato o meno finto
func levelblock():
	var temp = Saving.get(associatePositionNameLevel())
	if !temp[6]: return false
	else: return true

func associatePositionNameLevel():
	if actualLevel[0] == 0 and actualLevel[1] == 0:
		level = "LivelloTutorial"
	elif actualLevel[0] == 1 and actualLevel[1] == 0:
		level = "Livello1"
	elif actualLevel[0] == 0 and actualLevel[1] == 1:
		level = "Mercante"
	elif actualLevel[0] == 2 and actualLevel[1] == 0:
		level = "Livello2"
	return level

func _on_AnimationPlayer_animation_finished(anim_name):
	if !anim_name == "idle":
		token = true

func _on_ScrittaBlocco_animation_finished(_anim_name):
	token = true
	
	
func savingCoordinate(levelName, path):
	Saving.set("currentLevelName",levelName)
	Saving.set("currentLevelPosition",sprite.position)
	Saving.set("currentLevel",actualLevel)
	Saving.saveGame()
	SceneManager.goto_scene(path)

var grayZone
func setGrayZone():
	var y = 0
	var z = 0
	for i in get_child_count():
		var tempChild = get_child(i)
		if tempChild.name == listLevel[y]:
			var temp = Saving.get(listLevel[y])
			if temp[6]:
				tempChild.visible = false
				z = i
			if tempChild.name == "LivelloTutorial" and temp[6]:
				$Mercante.visible = false
			if y < listLevel.size()-1: 
				y+=1
	grayZone = get_child(z+1)
	if grayZone.name.find("Livello") != -1: 
		if z!=0 and grayZone.visible:
			grayZone.visible = false
			
			
func setHiddenTrash():
	var n = Saving.completedCount()
	var i = 0
	for child in get_children():
		if i == n: return
		if "Spazzatura" in child.get_name():
			child.visible = false
			i+=1
		
	
		

