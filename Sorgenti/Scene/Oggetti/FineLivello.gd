extends Area2D

onready var saveManager = Saving
onready var achivement = get_parent().get_node("UI/Achivement")

signal save
signal loadAchivement
func _ready():
	if connect("loadAchivement", get_parent().get_node("UI/IconaMenuImpostazioni"), "is_load_finelevel"): print("ERRORE CONNESSIONE")
	if connect("save", get_parent().get_node("UI/MonetePossedute"), "saveCoin"): print("ERRORE CONNESSIONE con monete possedute")

func _on_FineLivello_body_entered(body):
	if body.name == "Player":
		Saving.menu_state = Saving.MENU_STATES.LEVEL_END
		emit_signal("save")
		body.visible = false
		get_tree().paused = true
		$ManWalk.visible = true
		$AnimationPlayer.play("FineLivello")
		$AudioStreamPlayer2D.play()
		




func _on_AnimationPlayer_animation_finished(_anim_name):
	achivement.showAchivement()
	emit_signal("loadAchivement")
