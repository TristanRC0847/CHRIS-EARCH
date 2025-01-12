extends "res://métier/SallesElements/Objets/objet.gd"

func _on_dialogue_ended():
	super._on_dialogue_ended()
	get_node("/root/Main")._replace_music("res://Ressources/Sons/Musiques/04- Solitude Part.2.mp3")
