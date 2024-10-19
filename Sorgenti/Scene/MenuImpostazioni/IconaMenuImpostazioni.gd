extends Control

signal lose
signal open
var menuInUse
var directExit : bool = false
var eventPause : bool


func _ready():
	for child in get_parent().get_children():
		if child.name.find("HaiPerso") != -1:
			if connect("lose", get_parent().get_node("HaiPerso"), "youLose"): print("ERRORE CONNESSIONE con Hai perso")
		if child.name.find("Diario") != -1:
			if connect("open", get_parent().get_node("Diario"), "openSettings"): print("ERRORE CONNESSIONE con Diario")
	if get_parent().get_parent().name.find("Mercante") != -1:
		if connect("open", get_parent().get_parent(), "openSettings"): print("ERRORE CONNESSIONE con Mercante")


#in base alla scena padre richiama il gusto menu
func _on_Button_pressed():
	viewMenu()


func _process(_delta):
	eventPause = Input.is_action_just_pressed("ui_escape") 
	if eventPause:
		if directExit:
			get_tree().paused = false
			Saving.menu_state = Saving.MENU_STATES.NONE
			SceneManager.goto_scene("res://Scene/Game.tscn")
		elif $Panel.visible:  
			$Panel.visible = false
			menuInUse.visible = true
			menuInUse.focus()
		elif Saving.menu_state == Saving.MENU_STATES.DIARY:
			emit_signal("open")
		else:
			viewMenu()

func viewMenu():
	if Saving.menu_state == Saving.MENU_STATES.DIARY:
		get_parent().get_child(3).showDiary()
	if Saving.menu_state == Saving.MENU_STATES.UPGRADE: return
	if get_parent().get_parent().name.find("Livello") != -1: 
		menuInUse = $MenuImpostazioniLivello
	else: 
		menuInUse = $MenuImpostazioniMappa
	menuInUse.showMenu()
	var state = Saving.menu_state
	var optionState = Saving.MENU_STATES.OPTIONS
	var noneState = Saving.MENU_STATES.NONE
	Saving.menu_state = optionState if state == noneState else noneState
	
	
	
func lose():
	emit_signal("lose")
	directExit = true
func is_load_finelevel():
	directExit = true

func showOptions():
	$Panel.visible = true
	if $MenuImpostazioniLivello.visible: $MenuImpostazioniLivello.visible = false
	else: $MenuImpostazioniMappa.visible = false
	$Panel/Opzioni/Difficulty/OptionButton.grab_focus()
