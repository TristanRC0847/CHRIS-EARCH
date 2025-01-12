extends "res://métier/SallesElements/Objets/objet.gd"

func _on_dialogue_ended():
	get_tree().get_current_scene()._replace_sceneDialogue("res://métier/Salles/01.5-CheminAlpha/5- Choix final/03-1 Vraie Fin.tscn",true) 
