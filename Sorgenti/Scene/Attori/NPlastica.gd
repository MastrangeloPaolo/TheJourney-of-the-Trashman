extends KinematicBody2D

onready var configManager = get_node("/root/Config")

onready var gravity = configManager.getProperty("plastic_enemy","gravity")
var speed
var durationTimerRevive
var damage




var velocity := Vector2.ZERO



onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight
onready var collisionTimer = $CollisionTimer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var timerRevive = $TimerRevive


var death : bool = false


# This function is called when the scene enters the scene tree.
# We can initialize variables here.
signal iAmHere #viene mandato al menu impostazioni per aggiornare il totale di nemici
signal knock
func _ready():
	if connect("knock", get_parent().get_node("Player"), "knockback"): print("ERRORE CONNESSIONE con player")
	if connect("destroy", get_parent().get_node("UI/IconaMenuImpostazioni/MenuImpostazioniLivello"), "enemy_Destroy"): print("ERRORE CONNESSIONE con UI/MenuImpostazioni nPlastica")
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
		velocity = move_and_slide(velocity,Vector2.UP)	
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





#se gli sprite sono rivolti verso destra e la posizione del palyer è < di quella del nemico, il player lo prende di schiena
#se sono verso sinistra e la pos. del player è > di pos. nemico, nemico preso alle spalle

#oltre a settare la maschera se il giocatore tocca alle spalle il nemico esso non si girerà
func _on_Body_body_entered(body):
	if !death:
		if body.name == "Player":
			setMask()
			if !playerIsAttackShoulders(body.position.x, body.sprite.flip_h) and !position.y > body.position.y + 35:
					velocity.x= -velocity.x
					emit_signal("knock",sprite.flip_h)

#controlla che il nemico non sia attaccato dalle spalle
#se gli sprite sono rivolti verso destra e la posizione del palyer è < di quella del nemico, il player lo prende di schiena
#se sono verso sinistra e la pos. del player è > di pos. nemico, nemico preso alle spalle
func playerIsAttackShoulders(playerPositionX, playerSpriteLook):
	var isShoulders : bool = false
	if (playerSpriteLook == true) && (sprite.flip_h == true):
		if (playerPositionX < position.x):
			isShoulders = true
	elif (playerSpriteLook == false) && (sprite.flip_h == false):
		if (playerPositionX > position.x):
			isShoulders = true
	return isShoulders

func setMask():
	set_collision_mask_bit(1,false)
	collisionTimer.start()
func _on_CollisionTimer_timeout():
	set_collision_mask_bit(1,true)


func _on_HitBox_body_entered(body):
	if body.name == "Player":
		if death and $TimerNoCollect.is_stopped():
			body.set_collision_mask_bit(2,true)
			destroy()
		#il nemico è alto 45
		elif !death and position.y > body.position.y + 35 and !body.isInvicible:
			$TimerNoCollect.start()
			body.set_collision_mask_bit(2,false)
			death = true
			animation.play("Morte", -1, 1.5)
			timerRevive.wait_time = durationTimerRevive
			timerRevive.start()



#quando i varrà 2, sarà la seconda volta che l'animazione "Morte" finisce questo implica che il personaggio è tornato in vita
var i = 0
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Morte":	
		i +=1
		if i == 2:
			death = false
			i = 0
	if anim_name == "Raccolto":
		queue_free()

func _on_TimerRevive_timeout():
	animation.play_backwards("Morte")

signal destroy
func destroy():
	$AnimationPlayer.play("Raccolto")
	velocity = Vector2.ZERO
	emit_signal("destroy")


	
	
	#velocity = Vector2.ZERO
	

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





