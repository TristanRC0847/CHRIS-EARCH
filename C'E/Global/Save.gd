extends Node

const SAVE_PATH = "user://save.json"
const TEMP_SAVE_PATH = "user://save_temp.json"

#region Gestion du fichier de sauvegarde

## Méthode permettant de sauvegarder le jeu
func save(current_room : String) :
	
	save_section("current_scene",current_room)
	
	var tempSave = load_temp_save()
	
	var fichier = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	fichier.store_string(JSON.stringify(tempSave))
	fichier.close()
	
	# Réinitialisation du fichier temporaire avec la salle actuelle
	initialisation_temp_save()

## Méthode permettant de supprimer le fichier temporaire de sauvegarde
func delete_temp_save():
	if FileAccess.file_exists(TEMP_SAVE_PATH):
		DirAccess.remove_absolute(TEMP_SAVE_PATH)

## Méthode permettant de savoir si oui ou non une sauvegarde existe
func save_exists()-> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Méthode permettant d'initialiser le fichier de sauvegarde du jeu en lançant une nouvelle partie
func initialization():
	
	# Suppression des fichiers existants
	delete_temp_save()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	# Copie du template de sauvegarde vers la nouvelle sauvegarde
	var template = FileAccess.open("res://Ressources/Data/save.json",FileAccess.READ)
	var templateContenu = template.get_as_text()
	template.close()
	
	var save = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	save.store_string(templateContenu)
	save.close()
	
	# Initialisation du fichier temporaire par la même occasion
	initialisation_temp_save()

#endregion

#region Gestion du fichier de sauvegarde temporaire

## Méthode permettant d'initialiser le fichier de sauvegarde temporaire à partir de celui de base
func initialisation_temp_save():
	# Copie du contenu de base
	var save = FileAccess.open(SAVE_PATH,FileAccess.READ)
	var saveContenu = save.get_as_text()
	save.close()
	
	var tempSave = FileAccess.open(TEMP_SAVE_PATH,FileAccess.WRITE)
	tempSave.store_string(saveContenu)
	tempSave.close()


## Méthpode permettant de charger une section du fichier de sauvegarde en particulier
func load_section(section : String) :
	# Initialisation du fichier temporaire de sauvegarde s'il n'existe pas encore
	if (!FileAccess.file_exists(TEMP_SAVE_PATH)):
		initialisation_temp_save()
	
	var fichier = FileAccess.open(TEMP_SAVE_PATH, FileAccess.READ)
	var contenu = fichier.get_as_text()
	fichier.close()
	
	var json = JSON.parse_string(contenu)
	
	# Renvoie la section une fois le fichier "dé-jsoné"
	if (json) and (section in json):
		return json[section]

## Méthode permettant de sauvegarder une section dans le fichier de sauvegarde temporaire
func save_section(section : String, data):
	var dataTempSave = load_temp_save()
	dataTempSave[section] = data
	var fichier = FileAccess.open(TEMP_SAVE_PATH,FileAccess.WRITE)
	fichier.store_string(JSON.stringify(dataTempSave))
	fichier.close()

## Méthode permettant de charger le fichier de sauvegarde temporaire entier
func load_temp_save():
	var fichier = FileAccess.open(TEMP_SAVE_PATH,FileAccess.READ)
	var contenuFichier = JSON.parse_string(fichier.get_as_text())
	fichier.close()
	
	return contenuFichier

#endregion

#region Gestion d'événements

## Méthode permettant d'enregistrer un événement dans le fichier de sauvegarde
func save_event(chapitre : String ,evenement : String) :
	var evenements = load_section("evenements")
	# Permet de créer le chapitre s'il n'existait pas encore (de sorte qu'il n'y ait pas besoin de retoucher au fichier de sauvegarde pour ajouter un chapitre)
	if not chapitre in evenements :
		evenements[chapitre] = []
	if not evenement in evenements[chapitre]:
		evenements[chapitre].append(evenement)
		save_section("evenements",evenements)

## Méthode permettant de savoir si oui ou non un événement a été complété
func is_event_completed(chapitre : String, evenement : String) -> bool :
	var evenements = load_section("evenements")
	return (evenement in evenements[chapitre])

#endregion

#region Gestion des choix

## Méthode permettant de récupérer un choix sauvegardé
func get_choix(choix : String) -> int:
	var choixTemp = load_section("choix")
	return choixTemp.get(choix,0)

## Méthode permettant de définir un choix dans la sauvegarde
func set_choix(choix : String, valeur : int):
	var choixTemp = load_section("choix")
	choixTemp[choix] = valeur
	save_section("choix",choixTemp)

#endregion

#region Gestion de la scène

## Méthode permettant de récupérer le chemin vers la dernière scène enregistrée
func get_current_scene() -> String :
	var save = load_temp_save()
	return save.get("current_scene","res://métier/Salles/01- Introduction/IntroMap-01.tscn")

#endregion
