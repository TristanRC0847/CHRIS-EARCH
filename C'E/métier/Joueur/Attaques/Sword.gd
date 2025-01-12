extends Area2D

# Variable définissant si l'arme se génère ou non
var generating = true

# Direction de l'arme
var direction

# Vitesse de l'arme
@export var speed = 15
# Axe x actuel de la fonction exponentielle définissant la vitesse
var current_speed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "generation"

func _setter(typeDirection,PlayerPosition) :
	position += PlayerPosition
	direction = typeDirection
	match typeDirection :
		TypeDirection.Direction.LEFT:
			rotation_degrees -= 270
		TypeDirection.Direction.RIGHT:
			rotation_degrees -= 90
		TypeDirection.Direction.TOP:
			$AnimatedSprite2D.flip_v = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): # L'animation se joue en permanence
	if generating == true :
		$AnimatedSprite2D.play()
	else :
		# Vitesse exponentielle : lente au début, tend vers une certaine vitesse et 
		match direction :
			TypeDirection.Direction.LEFT:
				position.x -= (-speed)*(0.9**current_speed) + speed
			TypeDirection.Direction.RIGHT:
				position.x += (-speed)*(0.9**current_speed) + speed
			TypeDirection.Direction.TOP:
				position.y -= (-speed)*(0.9**current_speed) + speed
			TypeDirection.Direction.BOTTOM :
				position.y += (-speed)*(0.9**current_speed) + speed
		current_speed += 1

#Quand la création est finie, on attaque et quand l'animation d'attaque est finie, on détruit l'objet
func _on_animation_finished(): 
	generating = false
