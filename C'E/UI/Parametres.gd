extends Control

@export var pauseMenu = false

#region Initialisation

func _ready():
	$MarginContainer/VBoxContainer/HBoxContainer/RetourMenu.connect("pressed",_on_parameters_save)
	$"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer/HBoxContainer/OptionButton".connect("item_selected",load_menu)
	$"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer2/HBoxContainer/ModePleinEcran".connect("pressed",_on_fullscreen_pressed)
	
	$MarginContainer/VBoxContainer/VolMusique/TestMusicBouton.connect("pressed",test_musique)
	$MarginContainer/VBoxContainer/VolBruitages/TestBruitagesBouton.connect("pressed",test_bruitages)
	$MarginContainer/VBoxContainer/VolVoix/TestVoixBouton.connect("pressed",test_voix)
	
	
	$MarginContainer/VBoxContainer/VolGlobal/HSlider.connect("value_changed",_on_global_volume_changed)
	$MarginContainer/VBoxContainer/VolMusique/HSlider.connect("value_changed",_on_music_volume_changed)
	$MarginContainer/VBoxContainer/VolBruitages/HSlider.connect("value_changed",_on_bruits_volume_changed)
	$MarginContainer/VBoxContainer/VolVoix/HSlider.connect("value_changed",_on_voix_volume_changed)
	
	load_settings()
	load_menu()
	
	if (pauseMenu):
		$AudioStreamPlayer.playing = false
		hide()

func _ready_on_pausemenu():
	show()
	$AudioStreamPlayer.playing = true

func load_menu(index : int = -1):
	var langue : String
	if (index != -1):
		langue = Settings.get_code_language(index)
	else :
		langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/Menus/parametres.json",FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$MarginContainer/VBoxContainer/Parametres.text = texts.get("params")
		$"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer/HBoxContainer/Langues".text = texts.get("language")
		$"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer2/HBoxContainer/PleinEcran".text = texts.get("pleinEcranLabel")
		$"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer2/HBoxContainer/ModePleinEcran".text = texts.get("pleinEcran")		
		$MarginContainer/VBoxContainer/VolGlobal/GlobalLabel.text = texts.get("globalVol")
		$MarginContainer/VBoxContainer/VolMusique/MusiqueLabel.text = texts.get("musicVol")
		$MarginContainer/VBoxContainer/VolBruitages/BruitagesLabel.text = texts.get("bruitsVol")
		$MarginContainer/VBoxContainer/VolVoix/VoixLabel.text = texts.get("voicesVol")
		$MarginContainer/VBoxContainer/HBoxContainer/RetourMenu.text = texts.get("SaveAndReturn")
		$MarginContainer/VBoxContainer/VolMusique/TestMusicBouton.text = texts.get("testMusic")
		$MarginContainer/VBoxContainer/VolBruitages/TestBruitagesBouton.text = texts.get("testBruits")
		$MarginContainer/VBoxContainer/VolVoix/TestVoixBouton.text = texts.get("testVoix")
		
		fichier.close()
	else:
		print("Erreur lors de la lecture du fichier texte de Main Menu")



## Méthode permettant de charger les paramètres depuis le fichier de l'utilisateur
func load_settings():
	#Chargement de la langue
	var langue = Settings.settings.get("General", {}).get("language", 0)
	var option_button = $"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer/HBoxContainer/OptionButton"
	
	for lang in Settings.langues :
		option_button.add_item(lang.name,lang.id)
		if (lang.id == langue):
			option_button.select(langue)
	
	# Chargement des volumes
	$MarginContainer/VBoxContainer/VolGlobal/HSlider.value = Settings.settings.get("Audio",{}).get("global_volume",1.0)*100
	$MarginContainer/VBoxContainer/VolMusique/HSlider.value = Settings.settings.get("Audio",{}).get("musique_volume",1.0)*100
	$MarginContainer/VBoxContainer/VolBruitages/HSlider.value = Settings.settings.get("Audio",{}).get("bruitages_volume",1.0)*100
	$MarginContainer/VBoxContainer/VolVoix/HSlider.value = Settings.settings.get("Audio",{}).get("voix_volume",1.0)*100


#endregion

#region Sauvegarde

## Méthode permettant de sauvegarder les paramètres et de retourner au menu principal
func _on_parameters_save():
	save_settings()
	
	if (!pauseMenu):
		get_tree().change_scene_to_file("res://UI/MenuPrincipal.tscn")
	else :
		$TestBruitages.playing = false
		$TestVoix.playing = false
		$AudioStreamPlayer.playing = false
		get_parent().load_menu()
		hide()

## Méthode sauvegardant les paramètres avec le Singleton
func save_settings():
	# Sauvegarde de la langue
	Settings.settings["General"]["language"] = $"MarginContainer/VBoxContainer/Langue et Plein ecran/MarginContainer/HBoxContainer/OptionButton".selected
	
	# Sauvegarde des volumes
	Settings.settings["Audio"]["global_volume"] = $MarginContainer/VBoxContainer/VolGlobal/HSlider.value / 100
	Settings.settings["Audio"]["musique_volume"] = $MarginContainer/VBoxContainer/VolMusique/HSlider.value / 100
	Settings.settings["Audio"]["bruitages_volume"] = $MarginContainer/VBoxContainer/VolBruitages/HSlider.value / 100
	Settings.settings["Audio"]["voix_volume"] = $MarginContainer/VBoxContainer/VolVoix/HSlider.value / 100
	
	Settings.save_settings()



#endregion


#region Changements en direct

func _on_global_volume_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value / 100.0))

func _on_music_volume_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musiques"),linear_to_db(value / 100.0))

func _on_bruits_volume_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Bruitages"),linear_to_db(value / 100.0))

func _on_voix_volume_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voix"),linear_to_db(value / 100.0))

func test_voix():
	$TestVoix.playing = !$TestVoix.playing

func test_musique():
	$AudioStreamPlayer.stream_paused = !$AudioStreamPlayer.stream_paused

func test_bruitages():
	$TestBruitages.playing = !$TestBruitages.playing

func _on_fullscreen_pressed():
	Settings.set_fullscreen()

#endregion 
