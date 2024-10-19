extends KinematicBody2D

onready var configManager = get_node("/root/Config")

onready var gravity = configManager.getProperty("glass_enemy","gravity")
var speed
var durationTimerRevive
var damage
var bulletSpeed
var bulletDuration


onready var gun = get_node(@"Sparo")

onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight
onready var collisionTimer = $CollisionTimer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var timerRevive = $TimerRevive
onready var tappo= $TappoVetro
var death : bool = false
var velocity = Vector2.ZERO


# This function is called when the scene enters the scene tree.
# We can initialize variables here.
signal iAmHere #viene mandato al menu impostazioni per aggiornare il totale di nemici
func _ready():
	if connect("destroy", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "enemy_Destroy"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni")
	if connect("iAmHere", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "totalalObjectRicevitor"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni__iAmHere")
	emit_signal("iAmHere", self.name)
	
	
func setMask():
	set_collision_mask_bit(1,false)
	collisionTimer.start()
func _on_CollisionTimer_timeout():
	set_collision_mask_bit(1,true)

# è conessa a difficoltà, quando viene cambiata la difficoltà si aggiorna
func isChangeDifficulty(dur,dam,spe,bulletS,bulletD):
	durationTimerRevive = dur
	damage = dam
	speed = spe
	bulletSpeed = bulletS
	bulletDuration = bulletD 
	if sprite.flip_h == true: velocity.x = speed
	else: velocity.x = -speed

var direction
func _physics_process(delta):
	if !death:
		move(delta)
		velocity = move_and_slide(velocity, Vector2.UP)
		
		direction = flipSprite()

		if gun.shoot(bulletSpeed, bulletDuration, direction, "enemy"):
			$AnimationPlayer.play("Sparo")



func move(delta):
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
		tappo.position = Vector2(17,6)
		tappo.flip_h = true
		direction = true
	elif velocity.x < 0:
		sprite.flip_h = false
		tappo.flip_h = false
		tappo.position=Vector2(-18,6)
		direction = false
	return direction

#gestise la collisione con il proiettile nemico
func _on_HitBox_body_entered(body):
	if !death:
		if body.name.find("ProiettileGiocatore") != -1:
			$TimerNoCollect.start()
			body.set_collision_mask_bit(2,false)
			animation.play("MorteVetro")
			death = true
			timerRevive.wait_time = durationTimerRevive
			timerRevive.start()
		elif body.name == "Player":
			setMask()
	elif $TimerNoCollect.is_stopped() and body.name == "Player":
		body.set_collision_mask_bit(2,true)
		destroy()

func _on_TimerRevive_timeout():
	animation.play_backwards("MorteVetro")

#la seconda volta che l'animazione finisce implica che il personaggio è tornato in vita
var i = 0
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "MorteVetro":
		i +=1
		if i == 2:
			death = false
			i = 0
	if anim_name == "Raccolto":
		queue_free()
		
signal destroy
func destroy():
	$AnimationPlayer.play("Raccolto")
	velocity = Vector2.ZERO
	emit_signal("destroy")




#	var animation = get_new_animation()
#	if animation != animation_player.current_animation:
#		animation_player.play(animation)


#
#func get_new_animation():
#	var animation_new = ""
#	if _state == State.WALKING:
#		if _velocity.x == 0:
#			animation_new = "idle"
#		else:
#			animation_new = "walk"
#	else:
#		animation_new = "destroy"
#	return animation_new



