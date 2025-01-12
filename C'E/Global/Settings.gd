extends Node

## Chemin du fichier de configuration pour l'utilisateur
const CONFIG_PATH = "user://settings.cfg"

## Dictionnaire de paramètres
var settings = {}

## Liste des langues disponibles
var langues = [
	{"id":0,"code":"FR","name":"Français"},
	{"id":1,"code":"EN","name":"English"}
]

#region Initialisation

func _ready():
	# On crée le fichier de configuration s'il n'existe pas déjà
	if not FileAccess.file_exists(CONFIG_PATH):
		create_config()
	# Sinon, on charge juste les paramètres de base
	else :
		load_settings()
	
	set_audio()
	fullscreen_mode()

##Méthode permettant de charger les paramètres dans le singleton et d'initialiser les volumes
func load_settings():
	var config = ConfigFile.new()
	if ((config.load(CONFIG_PATH)) == OK):
		# Remplissage du dictionnaire avec les valeurs du fichier
		
		for section in config.get_sections():
			settings[section] = {}
			for key in config.get_section_keys(section):
				settings[section][key] = config.get_value(section,key)
	
	else:
		print("Le chargement du fichier de configuration a échoué")

## Méthode permettant de créer un fichier de configuration côté utilisateur et de l'initialiser dans l'application
func create_config():
	var file = FileAccess.open("res://Ressources/Data/settings.cfg",FileAccess.READ)
	
	
	if (file):
		var user_file = FileAccess.open(CONFIG_PATH,FileAccess.WRITE)
		user_file.store_string(file.get_as_text())
		user_file.close()
		file.close()
		
		load_settings()
		
		# Initialisation de la langue selon le language du PC
		var language = OS.get_locale_language()
		if (language == "fr") :
			settings["General"]["language"] = 0
		else :
			settings["General"]["language"] = 1
		save_settings()
	else :
		print("Le fichier de configuration n'a pas pu être lu/trouvé")

## Méthode permettant d'initialiser les bus audio de l'application
func set_audio():
# Initialisation des volumes de bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(settings.get("Audio",{}).get("global_volume",1.0)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musiques"),linear_to_db(settings.get("Audio",{}).get("musique_volume",1.0)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Bruitages"),linear_to_db(settings.get("Audio",{}).get("bruitages_volume",1.0)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voix"),linear_to_db(settings.get("Audio",{}).get("voix_volume",1.0)))

#endregion

#region Sauvegarde/Ecriture

## Méthode permettant de sauvegarder les paramètres actuels dans user://
func save_settings():
	var config = ConfigFile.new()
	
	# Remplissage des données
	for section in settings.keys():
		for key in settings[section].keys():
			config.set_value(section,key,settings[section][key])
	
	if ((config.save(CONFIG_PATH)) != OK):
		print("Erreur lors de la sauvegarde des paramètres")


#endregion

#region Getters

## Méthode permettant de récupérer le "code" d'un langage à partir de son identifiant
func get_code_language(language_id : int) -> String :
	var code = "FR"
	 
	for lang in langues:
		if lang.id == language_id:
			code = lang.code
	
	return code

#endregion

#region Gestion plein écran

## Méthode permettant de définir le mode fullscreen ou non à l'écran
func fullscreen_mode():
	var fullscreen = settings.get("General",{}).get("fullscreen",false)
	
	if fullscreen :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_size(Vector2(1280,720))
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

## Méthode permettant de définir le mode plein écran ou non
func set_fullscreen():
	settings["General"]["fullscreen"] = not settings["General"].get("fullscreen",false)
	fullscreen_mode()
	save_settings()


#endregion
