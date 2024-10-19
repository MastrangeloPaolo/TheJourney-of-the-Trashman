extends StaticBody2D


func unlock():
	$AudioStreamPlayer2D.play()
	visible = false

func _on_AudioStreamPlayer2D_finished():
	queue_free()
