extends Area2D

@export var current_room : String

func _ready():
	add_to_group("Sauvegarde")

## Méthode permettant de sauvegarder la partie actuelle, à partir d
func _save():
	get_node("/root/Main").save_game(current_room)
	queue_free()
