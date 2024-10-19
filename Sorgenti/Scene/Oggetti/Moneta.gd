class_name Coin
extends Area2D
# Collectible that disappears when the player touches it.d

onready var animation = $AnimationPlayer
var collect = false
func _ready():
	if connect("collecting", get_parent().get_node("UI/MonetePossedute"), "on_coin_increases"): print("ERRORE CONNESSIONE")
	animation.play("Moneta")

signal collecting
func _on_Coin_body_entered(body):
	if !body.isInvicible:
		if !collect:
			emit_signal("collecting")
			animation.play("Raccolta")
			collect = true
