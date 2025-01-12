extends Control

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	load_menu()
	check_save()
	
	$Boutons/VBoxContainer/Continuer.connect("pressed",_on_continuer_pressed)
	$Boutons/VBoxContainer/Quitter.connect("pressed",_on_quitter_pressed)
	$"Boutons/VBoxContainer/Nouvelle partie".connect("pressed",_on_nouvelle_partie_pressed)
	$"Boutons/VBoxContainer/Paramètres".connect("pressed",_on_params_pressed)
	$Reseaux/HBoxContainer/Reseaux.connect("pressed",_on_reseaux_pressed)

func load_menu():
	var langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/Menus/main_menu.json",FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$Boutons/VBoxContainer/Continuer.text = texts.get("continue")
		$"Boutons/VBoxContainer/Nouvelle partie".text = texts.get("NewGame")
		$"Boutons/VBoxContainer/Paramètres".text = texts.get("params")
		$Boutons/VBoxContainer/Quitter.text = texts.get("Quit")
		$Reseaux/HBoxContainer/Reseaux.text = texts.get("reseaux")
		$Commandes.text = texts.get("Commandes")
		
		fichier.close()
	else:
		print("Erreur lors de la lecture du fichier texte de Main Menu")

func check_save():
	if Save.save_exists():
		$Boutons/VBoxContainer/Continuer.visible = true


func _on_continuer_pressed():
	Save.delete_temp_save()
	Save.initialisation_temp_save()
	get_tree().change_scene_to_file("res://Manager/Main.tscn")

func _on_nouvelle_partie_pressed():
	Save.initialization()
	get_tree().change_scene_to_file("res://Manager/Main.tscn")

func _on_params_pressed():
	get_tree().change_scene_to_file("res://UI/Parametres.tscn")

func _on_quitter_pressed():
	get_tree().quit()

func _on_reseaux_pressed():
	get_tree().change_scene_to_file("res://UI/Reseaux.tscn")
