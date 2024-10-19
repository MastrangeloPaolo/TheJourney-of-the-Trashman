extends Area2D
# Collectible that disappears when the player touches it.


onready var animation = $AnimationPlayer
export var id : int
var prefix = "page"
var inBody : bool = false
var collect = false

signal objectSpawner
signal collecting

func _ready():
	$Label.text = "Press "+Settings.getKey("interact")
	action = Settings.getKey("interact")
	if connect("collecting", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "page_Found"): print("ERRORE CONNESSIONE con pageFound")
	if connect("collecting", get_parent().get_node("UI/Achivement"), "page_Found"): print("ERRORE CONNESSIONE con pageFound")
	if connect("objectSpawner", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "totalalObjectRicevitor"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni__iAmHere")
	emit_signal("objectSpawner", "page")


func _on_PaginaDiario_body_entered(body):
	if !body.isInvicible:
		$Label.visible = true
		inBody = true


func _process(_delta):
	if inBody == true:
		if !collect:
			upgreadText()
			if Input.is_action_just_pressed("interact"):
				$Label.visible = false
				emit_signal("collecting",id)
				animation.play("Raccolta")
				$Pickup.play()
				collect = true


func _on_PaginaDiario_body_exited(_body):
	$Label.visible = false
	inBody = false

var temp
var action
func upgreadText():
	temp = Settings.getKey("interact")
	if temp != action:
		$Label.text = "Press "+Settings.getKey("interact")
		action = temp
