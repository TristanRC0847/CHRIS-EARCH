extends Control

## Variable définissant si on est en mode pause ou non
@export var pauseMode = false

#region Initialisation

func _ready():
	
	# Caché au démarrage, mais toujours présent sur le Main
	hide()
	load_menu()
	
	$MarginContainer/VBoxContainer/Parametres.connect("pressed",_on_parametres_pressed)
	$MarginContainer/VBoxContainer/MenuPrincipal.connect("pressed",_on_menu_pressed)
	$MarginContainer/VBoxContainer/Quitter.connect("pressed",_on_quitter_pressed)
	

func load_menu():
	var langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/Menus/menu_pause.json",FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$Pause.text = texts.get("Menu")
		$MarginContainer/VBoxContainer/Continuer.text = texts.get("continue")
		$MarginContainer/VBoxContainer/Parametres.text = texts.get("params")
		$MarginContainer/VBoxContainer/MenuPrincipal.text = texts.get("menuPrincipal")
		$MarginContainer/VBoxContainer/Quitter.text = texts.get("Quit")
		$Commandes.text = texts.get("Commandes")
		
		fichier.close()
		$Commandes.text = texts.get("Commandes")
	else:
		print("Erreur lors de la lecture du fichier texte de Menu Pause")



#endregion

#region Activation/Désactivation du Menu

func pause():
	if (!$Parametres.visible) :
		pauseMode = !pauseMode
		visible = pauseMode
		
		# Gestion de la souris
		if (pauseMode):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#endregion

#region Boutons 

func _on_parametres_pressed():
	$Parametres._ready_on_pausemenu()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://UI/MenuPrincipal.tscn")

func _on_quitter_pressed():
	get_tree().quit()


#endregion 
