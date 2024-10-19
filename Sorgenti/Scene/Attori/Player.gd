extends KinematicBody2D

onready var configManager = get_node("/root/Config")
onready var flashPeriod = configManager.getProperty("player","flash_period")
onready var verticalRunMultiplier = configManager.getProperty("player","vertical_run_multiplier")
onready var horizontalRunMultiplier = configManager.getProperty("player","horizontal_run_multiplier")
onready var knockbackDuration = configManager.getProperty("player","knockback_duration")
onready var knockbackBaseJump = configManager.getProperty("player","knockback_speed")
onready var knockbackBaseSpeed = configManager.getProperty("player","knockback_jump")
onready var frictionForce = configManager.getProperty("player","friction_force")
export onready var moveSpeed = configManager.getProperty("player","knockback_speed")
onready var gravity = configManager.getProperty("player","gravity")
onready var stompingForce = configManager.getProperty("player","stomping_force")
onready var bulletSpeed = configManager.getProperty("player","bullet_speed")
onready var bulletDuration = configManager.getProperty("player","bullet_duration")
onready var jumpForce = configManager.getProperty("player","jump_force")
onready var speed = configManager.getProperty("player","speed")
onready var max_life = configManager.getProperty("player","max_life")

onready var animationP = $AnimationPlayer
onready var sprite = $Sprite
onready var invincibilityTimer = $InvincibilityTimer
onready var knockBackTimer = $KnockBackTimer
onready var lance = $Lance
onready var menuPause
onready var runTimer = $RunTimer
onready var flashIncrement = flashPeriod
onready var gun = get_node(@"Sparo")


var alive : bool = true
var isInvicible : bool = false

var isKnockBack : bool = false

var horizontalDirection = 0
var verticalDirection = 0
var running = false

var velocity := Vector2.ZERO

var isSeller = false
var isBlockMove : bool = false
var isUpgradeAbility : bool = false
var isJump = false
var temp = false

signal lose
signal deathline
func _ready():
	setAttributes()
	if get_parent().name.find("Mercante") == -1:
		if connect("life_changed", get_parent().get_node("UI/CuoreVita"), "on_player_life_changed"): print("ERRORE CONNESSIONE con Cambio vita")
		emit_signal("life_changed", max_life)
		if connect("lose", get_parent().get_node("UI/IconaMenuImpostazioni"), "lose"): print("ERRORE CONNESSIONE con IconaMenuImpostazioni")
		if connect("deathline",  get_parent().get_node("UI/HaiPerso"), "deathline"): print("ERR CONN con deathline")
		if connect("deathline",  get_parent().get_node("Camera2D"), "blockCamera"): print("ERR CONN con Camera2D")
	lance.set_collision_mask_bit(0,false)
	lance.set_collision_mask_bit(2,false)
	if get_parent().name == "Mercante": isSeller = true
	else: isSeller = false

#se alive = false significa che il giocatore è morto quindi cliccando un tasto dell'evento ui_esc esce dal livello
func _physics_process(delta):
	velocity.y += gravity*delta #con gravity 900 = circa 15
	if alive:
		if !isUpgradeAbility:
			setAnimation()
			if isKnockBack && is_on_floor(): 
				isKnockBack = false #se la fase di contraccolpo non è finita ma tocca terra la fa finire
			if !isKnockBack:
				velocity.x = 0
				move()
				flipSprite()
				handleLance()
			handleInvicibility()
	velocity = move_and_slide(velocity,Vector2.UP)



#
#    GESTIONE ATTRIBUTI
#

func setAttributes():
	setBulletSpeed()
	setLife()
	setbulletDuration()
	setjumpForce()
	setspeed()

func setLife():
	max_life += Saving.get("lifeLevel")*0.5
func setBulletSpeed():
	bulletSpeed += Saving.get("speedLevel")*3
func setbulletDuration():
	bulletDuration += Saving.get("durationBulletLevel")/10
func setjumpForce():
	jumpForce += Saving.get("jumpLevel")*2
func setspeed():
	speed += Saving.get("speedLevel")*3



#
#     GESTIONE INPUT E MOVIMENTO
#

var jumping
var justJumping
var releasedJumping
var stomping
var left
var justleft
var right
var justright
var eventShoot
var releasedLance
var releasedLeft
var releasedRight
var justShoot
var justLance
var lastDirection = 0
var currentDirection = 0

#acquisice gli input, gestisce il movimento e l'attaco verso il basso
func move():
	jumping = Input.is_action_pressed("jump")
	justJumping = Input.is_action_just_pressed("jump")
	releasedJumping = Input.is_action_just_released("jump")
	stomping = Input.is_action_pressed("stomp")
	left = Input.is_action_pressed("move_left")
	releasedLeft = Input.is_action_just_released("move_left")
	justleft = Input.is_action_just_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	justright = Input.is_action_just_pressed("move_right")
	releasedRight = Input.is_action_just_released("move_right")
	if !isSeller: justShoot = Input.is_action_just_pressed("shoot")
	justLance = Input.is_action_just_pressed("lance")

	
	verticalDirection = 0
	horizontalDirection = 0
	if(jumping): verticalDirection = -1
	elif(stomping): verticalDirection = +1 
	
	setHorizontalDirection()
	clingAndJumpFromWall()
	running = handleRun()

	#SALTO, quando viene rilasciato il tasto del salto la variabile viene decrementata così da avere un salto controllato
	if jumping and is_on_floor():
		$justJump.start()
		$AnimationSound.play("SuonoSalto")

		velocity.y = -jumpForce * (verticalRunMultiplier if running else float(1))
	elif releasedJumping and velocity.y < 0:
		velocity.y *= 0.6

	#Schiacciata, attacco per il nemico di plastica
	if stomping and !jumping and !is_on_floor():
		velocity.y += stompingForce
	
	if isBlockMove: blockmove()
	velocity.x = (speed if !running else speed*horizontalRunMultiplier)*horizontalDirection
	
	justTouchGroud()
	setCollisonOneWay()

var blockmoveDirection #viene aggiornato in _on_Area2D_area_entered solo quando entra nell'area bloccata
# se entra verso sinistra nell'area bloccata il movimento a sinistra sarà bloccato e viceversa
func blockmove(): 
	if blockmoveDirection == 1: 
		if right: horizontalDirection = 0
	elif left: horizontalDirection = 0


var lastMove = 0
func setHorizontalDirection():
	if right: horizontalDirection = 1
	if left: horizontalDirection = -1
	if right and left: horizontalDirection = -lastMove
	else: lastMove = horizontalDirection

var canRun
#restituisce true quando il player può correre
func handleRun():
	canRun = running
	if !isInvicible:
		if !isClimbing:
			if horizontalDirection!=0 and is_on_floor():
				if justleft or justright: 
					currentDirection = -1 if justleft else 1
					if !runTimer.is_stopped():
						if lastDirection == currentDirection:
							canRun = true
					else:
						runTimer.start()
				lastDirection = currentDirection 
			elif horizontalDirection == 0:
				canRun = false
		else: canRun = false
	else: canRun = false
	return canRun


#se sprite.flip_h == true lo sprite guarda a destra
func flipSprite():
	if velocity.x > 0:
		sprite.flip_h = true
		return 1
	elif velocity.x < 0:
		sprite.flip_h = false
		return -1


#gestise il rallentamento sul muro e il salto dal muro
var isClimbing : bool = false
var directionEvent
func clingAndJumpFromWall():
	is_dropping()
	if $justJump.is_stopped() and $justDrop.is_stopped() and (is_on_wall() and !is_on_floor()) and (right or left):
		if horizontalDirection == -1: directionEvent = justleft
		elif horizontalDirection == 1: directionEvent = justright
		isClimbing = true
		velocity.y *= frictionForce
		if  jumping and directionEvent and is_on_wall(): 
			isClimbing = false
			velocity.y = -jumpForce * verticalRunMultiplier
			$AnimationSound.play("SuonoSalto")
	else: isClimbing = false

var previuslyPosition = position.y
var firstDrop : bool = true
 
func is_dropping():
	if jumping:
		firstDrop = false
	elif is_on_floor(): firstDrop = true
	if previuslyPosition > position.y: previuslyPosition = position.y
	if firstDrop and $justJump.is_stopped() and !is_on_floor() and previuslyPosition < position.y:
		firstDrop = false
		previuslyPosition = position.y
		$justDrop.start()
	elif is_on_floor(): firstDrop = true


var attacklance : bool = false
# gestisce l'uso della lancia
func handleLance():
	if !isInvicible && justLance:
		attacklance = true
		lance.set_collision_mask_bit(0,true)
		lance.set_collision_mask_bit(2,true)
	if !attacklance:
		lance.set_collision_mask_bit(0,false)
		lance.set_collision_mask_bit(2,false)

#lance.translate(Vector2((directionLance*moveSpeedLance*delta), 0))
# controlla il wait time perchè viene modificato sia per bloccare la lancia sia per sbloccarla

#gestisce la parte grafica dell'invincibilità
func handleInvicibility():
	if isInvicible and invincibilityTimer.wait_time - invincibilityTimer.time_left > flashIncrement:
		flashIncrement += flashPeriod
		sprite.visible = !sprite.visible

#gestisce invincibilità
func setInvincibility():
	if !isInvicible:
		isInvicible = true
		set_collision_mask_bit(2,false)
		invincibilityTimer.start()

func _on_InvincibilityTimer_timeout():
	sprite.visible = true
	isInvicible = false
	flashIncrement = flashPeriod
	set_collision_mask_bit(2,true)

# annula la collision con i oneWai quando preme giù e si trova a terra
func setCollisonOneWay():
	if stomping and is_on_floor():
		set_collision_mask_bit(5,false)
		$OneWayTimer.start()

func _on_OneWayTimer_timeout():
	set_collision_mask_bit(5,true)

#
#	COLLISIONI CON I NEMICI
#

##gestisce la collisione con il nemico di carta
func hit():
		setInvincibility()


#viene richiamata da Nplastica quando deve eseguire il contraccolpo e in locale
func knockback(enemySpriteLook,localColl = false):
		var direction
		if horizontalDirection == 0 and !localColl:
			hit()
			damage(Saving.get("plastic_damage"))
		isKnockBack = true
		durating_knockback_timer()
		if enemySpriteLook: direction = 1
		else : direction = -1
		if localColl:
			velocity.y -= knockbackBaseJump
			velocity.x = knockbackBaseSpeed*direction
		else:
			velocity.y -= jumpForce #modifica l'altezza del contraccolpo
			velocity.x = moveSpeed*direction
		velocity = move_and_slide(velocity,Vector2.UP)
		
# durata della fase di contraccolpo
func durating_knockback_timer():
	knockBackTimer.wait_time = knockbackDuration
	knockBackTimer.start()
func _on_KnockBackTimer_timeout():
	isKnockBack = false

#
#	GESTIONE DELLA COLLISIONE DEI NEMICI CON LA HIT BOX
#

#vengono mandati prima gli argomenti dell'emit poi gli argomenti del segnale

#gestione delle collisioni con i nemici e derivati
func _on_Area2D_body_entered(body):
	if !isInvicible:
		set_collision_mask_bit(2,true)
		if body.name.find("NCarta") != -1:
			if !body.death:
				hit()
				damage(body.damage)
				knockback(body.sprite.flip_h, true)
		if body.name.find("NPlastica") != -1:
			if !body.death:
				#f position.y+30 < body.position.y: # se il giocatore attacca correttamente il nemico non deve prendere danno
				#	return
				hit()
				damage(body.damage)
				knockback(body.sprite.flip_h, true)
		if body.name.find("NVetro") != -1:
			if !body.death:
				hit()
				damage(body.damage)
				knockback(body.sprite.flip_h, true)
		if body.name.find("ProiettileNemico") != -1:
			hit()
			damage(body.damage)

	
	
#viene mandato per abbattere il muro di carta
signal unlock
#Sblocco muro bloccato
func _on_Lance_body_entered(body):
	if body.name.find("MuroBloccato") != -1:
		if connect("unlock", get_parent().get_node(body.name), "unlock"): print("ERRORE CONNESSIONE con Muro bloccato#")
		emit_signal("unlock")
		


#
#		GESTIONE DELLA VITA
#


signal life_changed
func damage(bodyDamage):
	max_life -= bodyDamage
	$Danno.play()
	emit_signal("life_changed", max_life)
	if max_life <= 0:
		death()

func death():
	set_collision_mask_bit(2,false)
	velocity.x = 0
	velocity = move_and_slide(velocity,Vector2.UP)
	animationP.play("Morte")
	alive = false


#
# 	GESTIONE ANIMAZIONI
#
var switch : bool = false
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Morte":
		set_collision_mask_bit(2,false)
		emit_signal("lose")
	elif !anim_name == "Idle":
		animationAttackToken = true
	if anim_name == "AttaccoLanciaDx" or anim_name == "AttaccoLanciaSx":
		attacklance = false
	if anim_name == "LancioBusta":
		var directionShot
		if sprite.flip_h: directionShot = true
		else: directionShot = false
		gun.shoot(bulletSpeed, bulletDuration, directionShot, "player") #quando finisce l'animazione del lancio della busta, la spara
	if anim_name == "Scalata":
		switch = true

#le animazione d'attacco hanno la priorità, il token rappresenta la priorità. quando è false, le animazioni di movimento non possono partire
var animationAttackToken : bool = true
func setAnimation():
	if (!isInvicible || attacklance) and justLance:
		if sprite.flip_h: animationP.play("AttaccoLanciaDx")
		else: animationP.play("AttaccoLanciaSx")
		animationAttackToken = false
	elif !isInvicible and justShoot:
		_on_AnimationPlayer_animation_finished("AttaccoLanciaDx")
		_on_AnimationPlayer_animation_finished("AttaccoLanciaSx")
		animationP.play("LancioBusta")
		animationAttackToken = false
	if !isClimbing:
		settingsAnimationClimbing()
	if animationAttackToken:
		if  horizontalDirection == 0:
			animationP.play("Idle")
		elif isClimbing:
			settingsAnimationClimbing()
			animationP.play("Scalata" if !switch else "ScalataTest2")
		elif running: 
			animationP.play("Corsa")
		elif horizontalDirection != 0: 
			animationP.play("Camminata")


var canStartTimer : bool = true
func settingsAnimationClimbing():
	if isClimbing:
		if sprite.flip_h == true: $RayCast2D.position.x = 22
		else: $RayCast2D.position.x = -9
		if !$RayCast2D.is_colliding():
			$Scivolamento.visible = false
			$Scivolamento3.visible = false
			$Scivolamento.emitting = false
			$Scivolamento3.emitting = false
		if sprite.flip_h == true:
			$Scivolamento.position.x = 13 
			$Scivolamento2.position.x = 12
			$Scivolamento3.position.x = 13
		else:
			$Scivolamento.position.x = -15
			$Scivolamento2.position.x = -14
			$Scivolamento3.position.x = -15
	else:
		switch = false
		$Scivolamento.visible = false
		$Scivolamento2.visible = false
		$Scivolamento3.visible = false
		$Scivolamento.emitting = false
		$Scivolamento2.emitting = false
		$Scivolamento3.emitting = false


func _on_PlayerHitBox_area_entered(area):
	if area.name.find("DeathLine") != -1:
		emit_signal("deathline")
		death()
	elif area.name.find("AreaBlock") != -1:
		isBlockMove = true
		blockmoveDirection = horizontalDirection #blockmoveDirection serve a sapere da che lato si trova il blocco


func _on_PlayerHitBox_area_exited(area):
	if area.name.find("AreaBlock") != -1:
		isBlockMove = false


#richiamata da mercante
func pauseForUpgradeAbility():
	if isUpgradeAbility: isUpgradeAbility = false
	else: isUpgradeAbility = true

#
#  GESTIONE DEL SUONO
#

#serve per sapere il momento in cui viene toccata terra
onready var sound = $AnimationSound
onready var soundAttack = $AnimationSoundAttack
var tempPosition = 0
var i =0
func justTouchGroud():
	
	if !temp and !is_on_floor():
		temp = true
	if temp and is_on_floor():
		temp = false
		$Drop.play()
	
	if !isInvicible and justLance:
		soundAttack.play("Punteruolo")
	elif !isInvicible and justShoot:
		soundAttack.play("LancioBusta")
	
	#nel momento in cui il giocatore scende da un muro senza saltare blocca il suono
	if !(abs(position.y - tempPosition)<0.01) and verticalDirection == 0:
		tempPosition = position.y
		sound.stop()
	elif verticalDirection == 0 and horizontalDirection == 0:
		sound.stop()
	elif isClimbing:
		pass
	elif is_on_floor() and running and verticalDirection == 0:  
		sound.play("CorsaM")
	elif is_on_floor() and horizontalDirection != 0 and verticalDirection == 0: 
		sound.play("CamminataM")
		
	tempPosition = position.y


