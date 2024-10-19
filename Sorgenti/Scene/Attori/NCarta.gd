extends KinematicBody2D

onready var configManager = get_node("/root/Config")

onready var gravity = configManager.getProperty("paper_enemy","gravity")
var durationTimerRevive
var damage
var speed

var velocity = Vector2.ZERO


onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight
onready var collisionTimer = $CollisionTimer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var timerRevive = $TimerRevive


var death : bool = false



signal destroy 
signal iAmHere #viene mandato al menu impostazioni per aggiornare il totale di nemici
func _ready():
	if connect("destroy", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "enemy_Destroy"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni")
	if connect("iAmHere", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "totalalObjectRicevitor"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni__iAmHere")
	emit_signal("iAmHere", self.name)

# è conessa a difficoltà, quando viene cambiata la difficoltà si aggiorna
func isChangeDifficulty(dur,dam,spe):
	durationTimerRevive = dur
	damage = dam
	speed = spe
	if sprite.flip_h == true: velocity.x = speed
	else: velocity.x = -speed

func _physics_process(delta):
	if !death:
		move(delta)
		velocity = move_and_slide(velocity, Vector2.UP)
		flipSprite()


func move(delta):
	animation.play("Camminata")
	velocity.y += gravity * delta
	if not floor_detector_left.is_colliding():
		velocity.x=  speed
	if not floor_detector_right.is_colliding():
		velocity.x= -speed
	#quando si blocca riprende a camminare in base alla direzione dello sprite
	if velocity.x == 0:
		if sprite.flip_h == true: velocity.x += speed
		else: velocity.x -= speed
	#quando tocca un muro si gira
	if is_on_wall(): velocity.x = -velocity.x

func flipSprite():
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false


func _on_Body_body_exited(_body):
	setMask()

func setMask():
	set_collision_mask_bit(1,false)
	collisionTimer.start()

func _on_CollisionTimer_timeout():
	set_collision_mask_bit(1,true)
	
	
	

#func _on_Player_hit_paper():
func _on_Body_area_entered(area):
	if area.name == "Lance":
		if !death:
			death = true
			$TimerNoCollect.start()
			area.get_parent().set_collision_mask_bit(2,false)
			setMask()
			animation.play("MorteCarta")
			timerRevive.wait_time = durationTimerRevive
			timerRevive.start()
	
# l'area 2D sarà raggiungibile solo dopo aver ucciso il nemico
func _on_Raccolta_body_entered(body):
	if death and $TimerNoCollect.is_stopped():
		if body.name.find("Player") != -1:
			body.set_collision_mask_bit(2,true)
			destroy()

func _on_TimerRevive_timeout():
	animation.play_backwards("MorteCarta")

#la seconda volta che l'animazione finisce implica che il personaggio è tornato in vita
var i = 0
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "MorteCarta":	
		i +=1
		if i == 2:
			death = false
			i = 0
	if anim_name == "Raccolto":
		queue_free()

func destroy():
	$AnimationPlayer.play("Raccolto")
	velocity = Vector2.ZERO
	emit_signal("destroy")
	visible = false
	


