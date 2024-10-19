extends RigidBody2D

onready var animation_player = $AnimationPlayer
onready var timer = $Timer
onready var sprite = $Sprite

onready var configManager = get_node("/root/Config")

var damage
var bounceNumber

#quando il colpo viene sparato recupera la posizione di shotgun per determinare il verso dello sprite
func _ready():
	timer.connect("timeout", self, "onTimerTimeout")
	damage = Saving.get("bullet_damage")
	bounceNumber = Saving.get("bullet_bounce_number")
	if get_parent().position.x < 0: 
		sprite.flip_h = false
	else: 
		sprite.flip_h = true

func destroy(duration):
	timer.wait_time = duration
	timer.start()
	

# azzera il contatore del rimbalzo quando viene distrutta la pallottola
func reboundFree():
	rebound=0
	destroy(0.3)


func onTimerTimeout():
	animation_player.play("destroy")

var isStop = position.x
var rebound = 0
func _on_Bullet_body_entered(body):
	if body.name.find("Player") != -1:
		reboundFree()
	#può rimbalzare massimo 2 volte
	if body.name.find("Ground") != -1 or body.name.find("OneWay") != -1:
		rebound += 1
		if rebound <= bounceNumber: 
			$SuonoRimbalzo.play()
		if rebound == bounceNumber: 
			reboundFree()
		if isStop == position.x:
			reboundFree()

