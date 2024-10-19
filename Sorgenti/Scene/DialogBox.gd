extends Node2D

var dialogKey
var dialogIndex = 0
var charIndex = 1
var currentPhrase = ""
signal over
func _ready():
	if connect("over", get_node("../"), "isDialogOver"): print("ERRORE CONNESSIONE con Inizio")

func _process(_delta):
	if !self.visible: return
	if Input.is_action_just_pressed("interact"):
		if charIndex < currentPhrase.length():
			$Label.text = currentPhrase
			charIndex = currentPhrase.length()
		else: setNextPhrase()


#sezione MerchantDialog in properties.ini
func startDialog(sectionKey):
	dialogKey = sectionKey
	currentPhrase = ""
	dialogIndex = 0
	charIndex = 1
	setNextPhrase()
	self.visible = true
	$Timer.start()
	

func setNextPhrase():
	charIndex = 1
	currentPhrase = Config.getProperty(dialogKey,'s'+str(dialogIndex))
	if currentPhrase != null:
		$Label.text = currentPhrase[0]
		dialogIndex += 1
		$Timer.start()
	else:
		self.visible = false
		emit_signal("over")

func isOver():
	return currentPhrase==null

func _on_Timer_timeout():
	if currentPhrase!= null and charIndex < currentPhrase.length():
		$Label.text += currentPhrase[charIndex]
		charIndex+=1
		$Timer.start()
