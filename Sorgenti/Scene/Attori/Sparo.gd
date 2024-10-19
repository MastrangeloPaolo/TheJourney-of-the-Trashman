extends Position2D



const BulletPlayer = preload("res://Scene/Oggetti/ProiettileGiocatore.tscn")
const BulletEnemy = preload("res://Scene/Oggetti/ProiettileNemico.tscn")



onready var timer = $Cooldown

onready var configManager = get_node("/root/Config")

onready var cooldownPlayer = configManager.getProperty("player","bullet_cooldown")
onready var cooldownEnemy = configManager.getProperty("glass_enemy","bullet_cooldown")



var bullet

# spara, prende in input: velocità, tempo, direzione del proiettile, chi spara
func shoot(velocity, time, direction, whoShot):
	if not timer.is_stopped():
		return false
	
	#in base allo sprite cambia la direzione del proiettile
	if direction == true: velocity = abs(velocity)
	else: velocity = -abs(velocity) 
	flip_shotgun(direction)
	
	#istanzia bullet in base a chi lo richiama
	if whoShot == "enemy":
		timer.wait_time = cooldownEnemy
		bullet = BulletEnemy.instance()
	
	if whoShot == "player": 
		timer.wait_time = cooldownPlayer
		bullet = BulletPlayer.instance()
	
	bullet.global_position = global_position
	bullet.linear_velocity = Vector2(velocity, 0)
	
	bullet.set_as_toplevel(true)
	add_child(bullet)
	timer.start()
	bullet.destroy(time)
	return true


#in base alla posizione dello sprite cmbia la posizione della pistola
func flip_shotgun(direction):
	if direction == true:
		self.position.x = abs(self.position.x) 
	else:
		self.position.x = -abs(self.position.x)


