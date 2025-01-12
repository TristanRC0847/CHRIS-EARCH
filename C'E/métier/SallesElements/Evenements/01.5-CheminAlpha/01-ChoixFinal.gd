extends "res://métier/SallesElements/Evenements/DialogueEvenement.gd"

func _on_dialogue_ended():
	get_node("/root/Main")._replace_music("res://Ressources/Sons/Musiques/05- Un choix nécessaire.mp3")
	super._on_dialogue_ended()
