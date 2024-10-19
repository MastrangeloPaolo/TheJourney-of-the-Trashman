class_name ProiettileGiocatore
extends RigidBody2D

onready var animation_player = $AnimationPlayer
onready var timer = $Timer

onready var configManager = get_node("/root/Config")

onready var durationTimeBullet = configManager.getProperty("player","duration_time_bullet")


var hit : bool = false

func _ready():
	animation_player.play("Rotation")
	
func destroy(durationTime):
	timer.wait_time = durationTime
	timer.start()
	timer.connect("timeout", self, "onTimerTimeout")

func onTimerTimeout():
	animation_player.play("destroy")

func _on_Bullet_body_entered(body):
	if body.name.find("NVetro") != -1:
		queue_free()
		hit = true
		return hit
	else: queue_free()




