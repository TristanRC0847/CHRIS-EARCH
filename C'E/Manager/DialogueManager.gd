# DialogueManager.gd
extends Node

signal dialogue_started
signal next_dialogue_line(dialogue_line)
signal dialogue_ended

var current_dialogue = []
var dialogue_index = 0

var current_connected : Node
var current_node : CanvasLayer
var player : CharacterBody2D

## Méthode permettant de connecter les différents objets interactifs d'une scène à la méthode permettant de commencer un dialogue
func connect_interactables(scene : Node) :
	var interactables = scene.get_children()
	for interactable in interactables:
		if interactable.is_in_group("Interactable") :
			interactable.connect("start_dialogue",start_dialogue)
	if scene.is_in_group("Interactable") :
		scene.connect("start_dialogue",start_dialogue)

## Méthode permettant de stocker un juoeur (pour l'arrêter et le remettre en marche pendant et après un dialogue)
func setplayer(player : CharacterBody2D) :
	self.player = player

## Méthode d'initialisation d'un dialogue
func start_dialogue(chemin : String, textBox : CanvasLayer, connexion : Node):
	
	current_connected = connexion
	
	current_node = textBox
	current_node.connect("show_next_dialogue",show_next_dialogue)
	current_node.show_textbox()
	
	var language = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	if FileAccess.file_exists("res://Ressources/Textes/" + language + "/"  + chemin):
		current_dialogue = load_dialogue("res://Ressources/Textes/" + language + "/"  + chemin)
		# print(current_dialogue)
		dialogue_index = 0
		show_next_dialogue()
	else:
		push_error("Le dialogue suivant n'existe pas : ", chemin)

## Méthode permettant de charger un dialogue depuis un chemin de fichier donné
func load_dialogue(chemin : String):
	var file = FileAccess.open(chemin,FileAccess.READ)
	
	# Si aucun fichier n'est trouvé, on arrête la fonction ici et on affiche une erreur
	if file == null:
		push_error("Echec lors de l'ouverture de : ", file)
		return []
	
	var contenu = JSON.parse_string(file.get_as_text())
	if contenu == null:
		push_error("Echec lors du parcours du fichier JSON : ", file)
		return []
	
	return contenu

## Méthode permettant de montrer le dialogue suivant
func show_next_dialogue():
	if dialogue_index < current_dialogue.size():
		var dialogue_line = current_dialogue[dialogue_index]
		# On émet un signal pour afficher la prochaine ligne
		current_node.update_dialogue_display(dialogue_line)
		dialogue_index += 1
	else:
		end_dialogue()

## méthode mettant fin à un dialogue
func end_dialogue():
	current_dialogue = []
	dialogue_index = 0
	if (player) :
		player._on_dialogue_ended()
	current_connected._on_dialogue_ended()
	current_node.disconnect("show_next_dialogue",show_next_dialogue)
	current_node.hide_textbox()
