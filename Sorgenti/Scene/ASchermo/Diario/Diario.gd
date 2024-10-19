extends Control

onready var configManager = get_node("/root/Config")
onready var bottonStartScroll = configManager.getProperty("diary","bottonStartScroll")
onready var valueScrollofOneBotton = configManager.getProperty("diary","valueScrollofOneBotton")
onready var maxBottonOnScreen = configManager.getProperty("diary","maxBottonOnScreen")

onready var scrollbar = $Popup/Panel/ScrollContainer.get_h_scrollbar()
onready var Hbox = $Popup/Panel/ScrollContainer/HBoxContainer

var pageFound = Saving.get("pageFound")
var isOpen : bool = false
var isEmpty : bool = true
var isParentGame : bool = false
var countBotton = 0
var lastFocus = 0
var settingOpen : bool = false

func _ready():
	recoverPage()
	if get_parent().get_parent().name.find("Game") != -1:
		isParentGame = true


func _process(_delta):
	if isParentGame:
		if Input.is_action_just_pressed("interact"):
			showDiary()


func showDiary():
	
	if Saving.menu_state != Saving.MENU_STATES.NONE: return
	if !isOpen:
		get_tree().paused = true
		$Popup.show()
		if !isEmpty:
			$Popup/Panel/ScrollContainer/HBoxContainer.get_child(0).grab_focus()
		isOpen = true
		Saving.menu_state = Saving.MENU_STATES.DIARY	
	else:
		close()
		Saving.menu_state = Saving.MENU_STATES.NONE



func recoverPage():
	var bottonPage = preload("res://Scene/ASchermo/Diario/pageINdiary.tscn")

	var i = 0
	for page in pageFound:
		if page:
			isEmpty = false
			var button = bottonPage.instance()
			button.setBotton(str(i+1))
			$Popup/Panel/ScrollContainer/HBoxContainer.add_child(button)
		i+=1

func close():
	get_tree().paused = false
	$Popup.hide()
	isOpen = false

func _on_BottonDiary_pressed():
	showDiary()
	
	

func scrollFocus(bottonPosition):
	$SuonoScroll.play()
	if Hbox.get_child_count() >= maxBottonOnScreen:
		if countBotton >= bottonStartScroll:
			if bottonPosition > lastFocus:
				scrollbar.value += valueScrollofOneBotton
				countBotton +=1
			else:
				scrollbar.value -= valueScrollofOneBotton
				countBotton -=1
			lastFocus = bottonPosition
		else:
			countBotton +=1

func openSettings():
	get_tree().paused = false
	$Popup.hide()
	isOpen = false
	Saving.menu_state = Saving.MENU_STATES.NONE

