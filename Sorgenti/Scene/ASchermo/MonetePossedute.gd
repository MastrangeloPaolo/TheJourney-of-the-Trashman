extends Control


onready var dimentionPixelCoin = 32
onready var coin = $Monete
onready var panel = $Panel

export onready  var totCoin = Saving.get("totcoin")
onready var numberOfDigit = str(totCoin).length()

signal numberOfDigitIncrease

func _ready():
	if get_parent().name.find("Mercante") == -1:
		if connect("numberOfDigitIncrease", get_parent().get_node("CuoreVita"), "move_right"): print("ERRORE CONNESSIONE con UI/CuoreVita")
		if numberOfDigit != 1:
			emit_signal("numberOfDigitIncrease", numberOfDigit-1)
	if numberOfDigit != 1:
		panel.margin_right += dimentionPixelCoin * (numberOfDigit-1)
	coin.text = str(totCoin)


# Aggiorna il numero di monete raccolte, se aumenta il numero di cifre invia il segnale (per spostare la posizione dei cuori)
func on_coin_increases():
	totCoin += 1
	if numberOfDigit != str(totCoin).length():#se il numero di cifre è diverso aumenta la grandezza del pannello
		panel.margin_right += dimentionPixelCoin
		emit_signal("numberOfDigitIncrease",1)
		numberOfDigit = str(totCoin).length()
	coin.text = str(totCoin)

#richiamata da Achivement
func updateCoinText():
	Saving.get("totcoin")
	coin.text = str(totCoin)

func saveCoin():
	Saving.set("totcoin", totCoin)

	
