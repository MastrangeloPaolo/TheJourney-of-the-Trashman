extends Node2D





func isDialogOver():
	$AnimationPlayer.play_backwards("RitornoAlLivello")
	
func startDialog():
	get_node("../PlayerMan").visible = false
	Saving.menu_state = Saving.MENU_STATES.DIALOG 
	$AnimationPlayer.play("IncontroMercante",-1,0.5)
	$MercanteIdle/AnimationPlayer.play("MercanteIdle 2")
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "RitornoAlLivello": 
		visible = false
		get_node("../PlayerMan").visible = true
		Saving.menu_state = Saving.MENU_STATES.NONE
		Saving.set("newGame",false)
		Saving.saveGame()
	elif anim_name == "IncontroMercante":
		$DialogBox.startDialog("HelloWorld")
		$AnimationPlayer.play("idle",-1,0.8)


