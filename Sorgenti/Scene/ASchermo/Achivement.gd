extends Control

onready var enemylable = $Panel/EnemyDestroy
onready var pagelable = $Panel/PageFound
onready var time = $Panel/TimePassed
onready var timer = $Timer
onready var CClable = $Panel/CoinCollector
onready var CRlable = $Panel/CoinRecycler
onready var CSlable = $Panel/CoinSpeedrunner
onready var check = $Panel/SpuntaVerde
onready var check2 = $Panel/SpuntaVerde2
onready var check3 = $Panel/SpuntaVerde3
onready var animation = $AnimationPlayer

var totEnemy
var enemyDestroy 
var totPage
var pageFound
var passedTime
var totCoin = 0

onready var levelMenu = get_node("../../UI/IconaMenuImpostazioni/MenuImpostazioniLivello")

onready var configManager = Config

onready var nameLevel
onready var minTimeForFinishLevel
onready var achivement


func _ready():
	if connect("updateText", get_parent().get_node("MonetePossedute"), "updateCoinText"): print("ERRORE CONNESSIONE con Monete Possedute")


signal updateText
func showAchivement():
		visible = true
		animation.play("pannelAppearing")
		nameLevel = Saving.get("currentLevelName")
		minTimeForFinishLevel = configManager.getProperty("TimeForFinishLevels", nameLevel)
		achivement = Saving.get(nameLevel)
		
		passedTime = levelMenu.timer.time_left
		totEnemy = levelMenu.totEnemy
		enemyDestroy = levelMenu.enemyDestroy
		totPage = levelMenu.totPage
		pageFound  = levelMenu.pageFound
		
		#scrive i valori sulle lable
		pagelable.text = str(pageFound) + "/" + str(totPage)
		enemylable.text = str(enemyDestroy) + "/" + str(totEnemy)
		CClable.text = "+" + str(achivement[1])
		CRlable.text = "+" + str(achivement[3])
		CSlable.text = "+" + str(achivement[5])
		
		#var color = Color("ffb300")
		#CSlable.modulate = color
		achivement[6]=true # segna che il livello è stato finito
		var levelTime = printPastTime()
		time.text = levelTime + " < " + str(minTimeForFinishLevel)
		#controlla se gli achivement sono già stati presi o se rispettano i requisiti per essere presi, nel caso li fa diventare veri
		if !achivement[0]:
			if totEnemy == enemyDestroy: #enta nel secondo if solo se l'achivment è appena stato sbloccato
				totCoin += achivement[1]
				achivement[0] = true
				animation.queue("CoinC")
		else: 
			check.visible = true
			check.self_modulate = "ffffff"
		if !achivement[2]:
			if totPage == pageFound:
				totCoin += achivement[3]
				achivement[2] = true
				animation.queue("CoinF")
		else: 
			check2.visible = true
			check2.self_modulate = "ffffff"
		if !achivement[4]:
			if is_minor(levelTime,minTimeForFinishLevel):
				check3.visible = true
				totCoin += achivement[5]
				achivement[4] = true
				animation.queue("CoinS")
		else: 
			check3.visible = true
			check3.self_modulate = "ffffff"
			
		var temp = Saving.get("totcoin")
		Saving.set(nameLevel, achivement)
		Saving.set("totcoin",temp+totCoin)
		Saving.saveGame()
		emit_signal("updateText")
		
		animation.queue("flashingEsc")
		


var pastTime = 0
#calcola, il tempo passato, dal tempo che manca alla fine del timer e lo fa visualizzare
func printPastTime():
	pastTime = 4096 - passedTime
	var elapedSecond = int(floor(pastTime))
	var seconds = elapedSecond%60
	var minutes = (elapedSecond/60)%60
	var decimal = (pastTime - elapedSecond) * 100
	var timePast = "%02d:%02d:%02d" % [minutes, seconds, decimal]
	return timePast

#calcola se s1(tempo di gioco)  è minore di s2(tempo limite per Speedrunner)
func is_minor(s1: String, s2: String) -> bool:
	# Divide le stringhe nei loro componenti (minuti, secondi e decimi)
	var s1_components = s1.split(":")
	var s2_components = s2.split(":")

	# Estrae i componenti come interi
	var minuti1 = int(s1_components[0])
	var secondi1 = int(s1_components[1])
	var decimi1 = int(s1_components[2])

	var minuti2 = int(s2_components[0])
	var secondi2 = int(s2_components[1])
	var decimi2 = int(s2_components[2])

	# Calcola il totale dei decimi di secondo per ciascun tempo
	var totale_decimi1 = minuti1 * 600 + secondi1 * 10 + decimi1
	var totale_decimi2 = minuti2 * 600 + secondi2 * 10 + decimi2

	# Verifica se s1 è minore di s2
	return totale_decimi1 < totale_decimi2

func page_Found(id):
	var temp = Saving.get("pageFound")
	temp[id] = true
	Saving.set("pageFound", temp)
