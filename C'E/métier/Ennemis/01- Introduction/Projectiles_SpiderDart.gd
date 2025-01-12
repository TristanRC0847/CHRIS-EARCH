extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Destruction de l'objet quand il n'est plus visible à l'écran


func _on_body_entered(body):
	queue_free()# Destruction de l'objet s'il touche quelque chose
