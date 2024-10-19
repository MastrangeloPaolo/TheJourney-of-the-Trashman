extends Control
#
onready var animation = $AnimationPlayer

var line : bool = false

func youLose():
	if !line: 
		get_tree().paused = true
	$Panel.visible = true
	$SuonoSconfitta.play()
	animation.play("ApparizioneHaiPerso")
	animation.queue("LampeggioClickEsc")
	
#richiamata dal player quando muore per essere caduto fuori dal mondo
func deathline():
	line = true
