extends Button

class_name ButtonPage

onready var pageText

signal focus
func _ready():
		if connect("focus", get_node("../../../../../../Diario"), "scrollFocus"): print("ERRORE CONNESSIONE con diario")
func setBotton(pageName):
	$Label.text = pageName
	pageText = Config.getProperty("diary","page"+str(int(pageName)-1))


func _on_Button_focus_entered():
	get_node("../../../Panel/Text").text = pageText
	emit_signal("focus",self.rect_position.x)

