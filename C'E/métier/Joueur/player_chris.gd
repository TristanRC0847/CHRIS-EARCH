extends CharacterBody2D

#region Attributs Communs

## Vitesse actuelle du joueur
@export var speed = 400 # @export = affiche la variable dans l'inspecteur pour qu'on la modifie dedans si besoin

## Vitesses maximales et minimales du joueur
var minSpeed = 400
var maxSpeed = 800

## var screen_size
signal hit # Signal montrant que le joueur est touché par autre chose

## état actuel du joueur (dialogue, attaque, ...)
@export var state = Player_State.RUN

## Mode actuel du joueur (normal ou d'attaque)
var mode = PlayerMode.NORMAL

## Direction actuelle du joueur (modifiée selon le mouvement)
var direction : TypeDirection.Direction = TypeDirection.Direction.BOTTOM

#endregion

#region Attributs Combat
var Sword = preload("res://métier/Joueur/Attaques/Sword.tscn")

var atk_cooldown : Timer
var canAttack = true

#endregion

#region Attributs Normal

var dialogue_cooldown : Timer
var canInteract = true

#endregion

#region Initialisation
##  Au lancement du jeu
func _ready(): 
	add_to_group("player")
	atk_cooldown = Timer.new()
	atk_cooldown.wait_time = 1.5
	atk_cooldown.one_shot = true
	dialogue_cooldown = Timer.new()
	dialogue_cooldown.set_wait_time(0.3)
	dialogue_cooldown.one_shot = true
	add_child(atk_cooldown)
	add_child(dialogue_cooldown)
	dialogue_cooldown.connect("timeout",_on_dialogue_timer_timeout)
	atk_cooldown.start()
	$InteractArea.area_entered.connect(_on_interactBody_entered)

func start(pos): 
	position = pos
	show()
	# On (ré)active la hitbox
	$CollisionShape2D.disabled = false 


#endregion

#region Process

## Méthode appelée en permanence pour mettre à jour l'état du joueur
func _process(delta): 
	# Si le joueur se déplace, peu importe le mode actuel, il bougera
	if (state == Player_State.RUN) :
		_move()



func _input(event):
	#if event.is_action_pressed("change_mode"):
		#_changeMode()
	if event.is_action_pressed("interact"):
		interact()
	
	# Si le joueur est en mode attaque, qu'il presse le bouton pour attaquer et que le timer n'est pas écoulé, il attaque
	if (mode == PlayerMode.ATTACK && event.is_action_pressed("attack") && canAttack) :
		_attack()
	# Si le joueur est actuellement en "état d'attaque", son animation se jouera
	if (state == Player_State.ATTACK && mode == PlayerMode.ATTACK) :
		$AnimatedSprite2D.play()

## Méthode de déplacement du joueur, peu importe son mode actuel
func _move() :
	# Définition du mouvement et attribution de la direction actuelle du joueur
	velocity = Vector2.ZERO # Direction et vitesse, initialisées à 0
	# On stocke temporairement la direction
	var startDirection = direction
	
	if Input.is_action_pressed("move_right"): # Si une touche est pressée, on modifie la velocity
		velocity.x +=1
		direction = TypeDirection.Direction.RIGHT
	if Input.is_action_pressed("move_left"):
		velocity.x -=1
		direction = TypeDirection.Direction.LEFT
	if Input.is_action_pressed("move_up"):
		velocity.y -=1
		direction = TypeDirection.Direction.TOP
	if Input.is_action_pressed("move_down"):
		velocity.y +=1
		direction = TypeDirection.Direction.BOTTOM
	
	if Input.is_action_just_pressed("acceleration"):
		speed = maxSpeed # On accélère si on appuie sur le bouton pour
	if Input.is_action_just_released("acceleration"): # On accélère si on appuie sur le bouton pour == 200 :
		speed = minSpeed # On annule l'accélération
	
	if velocity.length() > 0:
		# On normalise sa taille entre 0 et 1 et on multiplie par la vitesse et le temps
		velocity = velocity.normalized() * speed; 
		$AnimatedSprite2D.play()
		# On bouge si on ne sort pas de la salle
		move_and_slide()
	else:
		$AnimatedSprite2D.stop()
	
	# Si la direction actuelle est différente de la précédente, on va changer le sprite d'animation
	if (direction != startDirection) :
		# Stocke le mode actuel pour l'appeler dans le choix des sprites
		var currentMode : String
		match (mode) :
			# Si le joueur est en mode attaque :
			PlayerMode.ATTACK :
				currentMode = "atkMode_"
			PlayerMode.NORMAL :
				currentMode = "base_"
		
		# Choix du sprite
		match (direction) :
					TypeDirection.Direction.LEFT :
						$AnimatedSprite2D.animation = currentMode + "right"
						$AnimatedSprite2D.flip_h = true
					TypeDirection.Direction.RIGHT :
						$AnimatedSprite2D.animation = currentMode + "right"
						$AnimatedSprite2D.flip_h = false
					TypeDirection.Direction.BOTTOM:
						$AnimatedSprite2D.animation = currentMode + "down"
					TypeDirection.Direction.TOP:
						$AnimatedSprite2D.animation = currentMode + "up"

#endregion

#region Attaques


## Méthode permettant au joueur de créer une attaque
func _attack() :
	atk_cooldown.timeout.connect(_on_atk_timer_timeout)
	atk_cooldown.start()
	canAttack = false
	
	state = Player_State.ATTACK #On ne peut plus rien faire
	var swordatk = Sword.instantiate() # On crée une instance d'épée pour attaquer
	swordatk._setter(self.direction,position)
	get_parent().add_child(swordatk)
	match direction:
		TypeDirection.Direction.LEFT:
			$AnimatedSprite2D.animation = "attack_right"
			$AnimatedSprite2D.flip_h = true
		TypeDirection.Direction.BOTTOM:
			$AnimatedSprite2D.animation = "attack_down"
		TypeDirection.Direction.RIGHT:
			$AnimatedSprite2D.animation = "attack_right"
			$AnimatedSprite2D.flip_h = false
		TypeDirection.Direction.TOP:
			$AnimatedSprite2D.animation = "attack_up"

## Si le joueur était en mode attaque, quand son animation se termine, il retourne en mode normal
func _on_animated_sprite_2d_animation_finished():
	if (state == Player_State.ATTACK) :
		state = Player_State.RUN

func _on_atk_timer_timeout():
	canAttack = true
	atk_cooldown.timeout.disconnect(_on_atk_timer_timeout)
#endregion

#region ChangeMode

## Méthode permettant de changer le mode du joueur
func _changeMode() :
	if (mode == PlayerMode.NORMAL) :
		mode = PlayerMode.ATTACK
		$AnimatedSprite2D.animation = "atkMode_down"
		$AnimatedSprite2D.frame = 0
	elif (mode == PlayerMode.ATTACK) :
		mode = PlayerMode.NORMAL
		$AnimatedSprite2D.animation = "base_down"
		$AnimatedSprite2D.frame = 0
#endregion

#region Interactions Dialogue

## Méthode permettant d'interagir avec un objet
func interact():
	var overlapping = $InteractArea.get_overlapping_areas()
	# print ("Overlap : ", overlapping)
	for objet in overlapping:
		#print("Distance to " + objet.name + ": " + str($InteractArea.global_position.distance_to(objet.global_position)))
		if (objet.is_in_group("Interactable")) && (canInteract) && (objet.direction == direction || objet.direction == TypeDirection.Direction.NONE):
			# print("Objet d'interaction : " + objet.name)
			canInteract = false
			objet.interact()
			state = Player_State.DIALOGUE
			$AnimatedSprite2D.stop()

## Méthode forçant une interaction avec un objet quand ce dernier en nécessite une
func _on_interactBody_entered(area : Area2D):
	# print("Area entered: ", area.name)
	if area.is_in_group("DialogEvent") and state != Player_State.DIALOGUE:
		canInteract = false
		area.interact()
		state = Player_State.DIALOGUE
		$AnimatedSprite2D.stop()
	else : if area.is_in_group("Porte"):
		area._changeRoom()
	else : if area.is_in_group("Sauvegarde"):
		area._save()
	

## Méthode permettant de remettre à 0 l'état du joueur
func _on_dialogue_ended():
	speed = minSpeed
	state = Player_State.RUN
	dialogue_cooldown.start()

func _on_dialogue_timer_timeout():
	canInteract = true
	print("test")


#endregion
