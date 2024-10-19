extends Node2D

onready var pannelSpeed = $Panel/Panel2
onready var pannelLife = $Panel/Panel3
onready var pannelJump = $Panel/Panel4
onready var pannelDurationB = $Panel/Panel5
onready var pannelSpeedB = $Panel/Panel6

onready var lableSpeed = $Panel/LabelCoinSpeed
onready var lableLife = $Panel/LabelCoinLife
onready var lableJump = $Panel/LabelCoinJump
onready var lableDurationB = $Panel/LabelCoinDurationB
onready var lableSpeedB = $Panel/LabelCoinSpeedB

onready var cuoreVita = $UI/CuoreVita
onready var configManager = get_node("/root/Config")
onready var minCoinForUpdate = configManager.getProperty("player","minCoinForUpdate")
onready var maxLife = configManager.getProperty("player","max_life")
onready var doorPosition = configManager.getProperty("seller","doorPosition")
onready var startTalk = configManager.getProperty("seller","startTalk")


var totcoin
var speedLevel
var lifeLevel
var jumpLevel
var gunLevel
var durationBulletLevel
var speedBulletLevel

var virtualCoin = totcoin
var virtualspeedLevel = speedLevel
var virtuallifeLevel = lifeLevel
var virtualjumpLevel = jumpLevel

var virtualdurationBulletLevel = durationBulletLevel
var virtualspeedBulletLevel = speedBulletLevel

onready var mercante = int($MercanteIdle.position.x)
onready var player = int($Player.position.x)
signal upgradeAbility


func _ready():
	if connect("upgradeAbility", get_node("Player"), "pauseForUpgradeAbility"): print("ERRORE CONNESSIONE con player")

	totcoin = Saving.get("totcoin")
	speedLevel = Saving.get("speedLevel")
	lifeLevel = Saving.get("lifeLevel")
	jumpLevel = Saving.get("jumpLevel")
	durationBulletLevel = Saving.get("durationBulletLevel")
	speedBulletLevel = Saving.get("speedBulletLevel")
	cuoreVita.updateMaxLife(maxLife+lifeLevel*0.5)
	virtualCoin = totcoin
	virtualspeedLevel = speedLevel
	virtuallifeLevel = lifeLevel
	virtualjumpLevel = jumpLevel
	virtualdurationBulletLevel = durationBulletLevel
	virtualspeedBulletLevel = speedBulletLevel

	updateLabelsCoin(lableSpeed, speedLevel)
	updateLabelsCoin(lableLife, lifeLevel)
	updateLabelsCoin(lableJump, jumpLevel)
	updateLabelsCoin(lableDurationB, durationBulletLevel)
	updateLabelsCoin(lableSpeedB, speedBulletLevel)

	redimensionBlackPannels(pannelSpeed, speedLevel)
	redimensionBlackPannels(pannelLife, lifeLevel)
	redimensionBlackPannels(pannelJump, jumpLevel)
	redimensionBlackPannels(pannelDurationB, durationBulletLevel)
	redimensionBlackPannels(pannelSpeedB, speedBulletLevel)

var isPause : bool = false
var i = 0

var canOpenPanel = false
	
func _process(_delta):
	player = int($Player.position.x)
	if player > startTalk:
		$MercanteIdle.flip_h = true
		canOpenPanel = true
	else:
		 $MercanteIdle.flip_h = false
		 canOpenPanel = false
	if player <= doorPosition:
		SceneManager.goto_scene("res://Scene/Game.tscn")

func openPannel():
	$Panel.visible = true
	$Panel/Speed.grab_focus()
	$UI/AnimationPlayer.play("VirtualCoin")
	get_tree().paused = true
	isPause = true
	emit_signal("upgradeAbility")
	Saving.menu_state = Saving.MENU_STATES.UPGRADE
	
	
func closePannel(settings = false):
	if !settings: get_tree().paused = false
	$UI/AnimationPlayer.play_backwards("VirtualCoin",-1)
	isPause = false
	$Panel.visible = false
	emit_signal("upgradeAbility")
	Saving.menu_state = Saving.MENU_STATES.NONE
	get_tree().paused = false
	_on_Reset_pressed()

func _on_Speed_pressed():
	virtualspeedLevel = onBottomPressed(virtualspeedLevel, pannelSpeed, lableSpeed)


func _on_heart_pressed():
	virtuallifeLevel = onBottomPressed(virtuallifeLevel, pannelLife, lableLife)

func _on_Jump_pressed():
	virtualjumpLevel = onBottomPressed(virtualjumpLevel, pannelJump, lableJump)

func _on_durationBullet_pressed(): 
	virtualdurationBulletLevel = onBottomPressed(virtualdurationBulletLevel, pannelDurationB, lableDurationB)

func _on_speedBullet_pressed():
	virtualspeedBulletLevel = onBottomPressed(virtualspeedBulletLevel, pannelSpeedB, lableSpeedB)
	
	
func _on_Done_pressed():
	totcoin = virtualCoin
	lifeLevel = virtuallifeLevel
	speedLevel = virtualspeedLevel
	jumpLevel = virtualjumpLevel
	durationBulletLevel = virtualdurationBulletLevel
	speedBulletLevel = virtualspeedBulletLevel
	cuoreVita.updateMaxLife(maxLife+lifeLevel*0.5)
	Saving.set("totcoin",virtualCoin)
	Saving.set("speedLevel",virtualspeedLevel)
	Saving.set("lifeLevel",virtuallifeLevel)
	Saving.set("jumpLevel",virtualjumpLevel)
	Saving.set("durationBulletLevel",virtualdurationBulletLevel)
	Saving.set("speedBulletLevel",virtualspeedBulletLevel)
	$UI/MonetePossedute.coin.text = str(virtualCoin)
	Saving.saveGame()
	closePannel()
	
func _on_Reset_pressed():
	virtualCoin = totcoin
	virtualspeedLevel = speedLevel
	virtuallifeLevel = lifeLevel
	virtualjumpLevel = jumpLevel
	virtualdurationBulletLevel = durationBulletLevel
	virtualspeedBulletLevel = speedBulletLevel
	
	updateLabelsCoin(lableSpeed, speedLevel)
	updateLabelsCoin(lableLife, lifeLevel)
	updateLabelsCoin(lableJump, jumpLevel)
	updateLabelsCoin(lableDurationB, durationBulletLevel)
	updateLabelsCoin(lableSpeedB, speedBulletLevel)
	
	$MonetePossedute2.coin.text = str(virtualCoin)
	resetDrimensionBlackPannels(pannelSpeed, virtualspeedLevel)
	resetDrimensionBlackPannels(pannelLife, virtuallifeLevel)
	resetDrimensionBlackPannels(pannelJump, virtualjumpLevel)
	resetDrimensionBlackPannels(pannelDurationB, virtualdurationBulletLevel)
	resetDrimensionBlackPannels(pannelSpeedB, virtualspeedBulletLevel)

func onBottomPressed(levelAbility, panel, lable):
	if calculateCoin(levelAbility):
		redimensionBlackPannels(panel)
		$MonetePossedute2.coin.text = str(virtualCoin)
		levelAbility+=1
		updateLabelsCoin(lable, levelAbility)
	else: 
		$UI/AnimationPlayer.play("flash", -1, 1.5)
	return levelAbility

#levelAbility intero che va da 1 a 10
func redimensionBlackPannels(panel, levelAbility = 1):
	panel.anchor_left = panel.anchor_left + levelAbility*0.770/10

func resetDrimensionBlackPannels(panel, levelAbility):
	panel.anchor_left = 0
	redimensionBlackPannels(panel, levelAbility)

func updateLabelsCoin(lable, levelAbility):
	lable.text = str(minCoinForUpdate * pow(2,levelAbility))
	
#restituisce un bool per segnalare se ha fatto o meno la sottrazione
var temp
func calculateCoin(levelAbility):
	temp = virtualCoin - minCoinForUpdate * pow(2,levelAbility)
	if temp >= 0:
		virtualCoin = temp
		return true
	else: return false

func updateVritualCoin():
	$MonetePossedute2.coin.text = str(virtualCoin)

#richiamata da icona menu impostazioni
func openSettings(isOpen):
	closePannel(isOpen)
