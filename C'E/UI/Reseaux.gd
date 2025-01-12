extends Control

func _ready():
	
	load_menu()
	
	$Bouton/HBoxContainer/RetourMenu.connect("pressed",_on_retourMenu_pressed)
	$Reseaux/VBoxContainer/BlueSky.connect("pressed",_on_BlueSky_pressed)
	$Reseaux/VBoxContainer/Discord.connect("pressed",_on_discord_pressed)
	$Reseaux/VBoxContainer/Tipeee.connect("pressed",_on_tipeee_pressed)
	$Reseaux/VBoxContainer/Twitter.connect("pressed",_on_twitter_pressed)
	$Reseaux/VBoxContainer/YouTube.connect("pressed",_on_youtube_pressed)

func load_menu():
	var langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/Menus/reseaux.json",FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$Bouton/HBoxContainer/RetourMenu.text = texts.get("return")	
		fichier.close()
	else:
		print("Erreur lors de la lecture du fichier texte des Réseaux")

func _on_retourMenu_pressed():
	get_tree().change_scene_to_file("res://UI/MenuPrincipal.tscn")

func _on_BlueSky_pressed():
	OS.shell_open("https://bsky.app/profile/tristanrc.bsky.social")

func _on_discord_pressed():
	OS.shell_open("https://discord.com/invite/ujcEyv9")

func _on_tipeee_pressed():
	OS.shell_open("https://fr.tipeee.com/tristanrc")

func _on_twitter_pressed():
	OS.shell_open("https://twitter.com/TristanRCC")

func _on_youtube_pressed():
	OS.shell_open("https://www.youtube.com/@TristanRC")
