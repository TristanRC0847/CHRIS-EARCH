extends CanvasLayer

#region Attributs

## Signal indiquant que la text box a besoin du dialogue suivant
signal show_next_dialogue
signal dialogue_ended

## Texte à afficher
var DialogBox : RichTextLabel
## Nom du personnage actuel
var NameBox : RichTextLabel
## Conteneur des dialogues
var container : CanvasLayer
## Alignement du texte (centre pour cinématique, gauche sinon)
@onready var content_align : String = "[left]"
## Etat de la boîte de texte (remplie ou non, déterminant si on va augmenter le ratio visible ou non)
var FullDialogBox : bool

## Vitesse à laquelle le texte avancera
var vitesseLecture : float
## Vitesse de lectur dépendant de la taille du texte
var vitesseTailleText : float

## Timer pour laisser un temps entre la fin d'un dialogue et le début d'un nouveau (éviter un spam trop rapide de la touche d'action)
var cooldown : Timer

## Contenu actuel des boîtes de dialogue (sous la forme d'un dictionnaire de données)
var dialogue_line = {
	"name":"",
	"text":""
}

## Dictionnaire de données pour chaque personnage (sa couleur associée, son audio, ...)
var characters_data = {
	"Chris": {
		"color": "white",
		"audio": "res://Ressources/Sons/Voix/Chris.mp3",
		"vitesseLecture" : 0.847
	},
	"Earch": {
		"color": "yellow",
		"audio": "res://Ressources/Sons/Voix/Earch.mp3",
		"vitesseLecture" : 0.847
	},
	"Hunter": {
		"color": "white",
		"audio": "res://Ressources/Sons/Voix/Vide.mp3",
		"vitesseLecture" : 0.847
	},
	"Neant": {
		"color": "black",
		"audio": "res://Ressources/Sons/Voix/Vide.mp3",
		"vitesseLecture" : 0.847
	},
	"R b   ": {
		"color": "gray",
		"audio": "res://Ressources/Sons/Voix/R_b.mp3",
		"vitesseLecture" : 0.1
	},
	"R ber ": {
		"color": "gray",
		"audio": "res://Ressources/Sons/Voix/R_ber_.mp3",
		"vitesseLecture" : 0.1
	},
	"R b  t": {
		"color": "gray",
		"audio": "res://Ressources/Sons/Voix/R_b__t.mp3",
		"vitesseLecture" : 0.1
	},
	"Robert" : {
		"color" : "green",
		"audio" : "res://Ressources/Sons/Voix/Robert.mp3",
		"vitesseLecture" : 0.25
	},
	"Robert V." : {
		"color" : "green",
		"audio" : "res://Ressources/Sons/Voix/Robert V.mp3",
		"vitesseLecture" : 0.4
	}
}


@onready var audio : AudioStreamPlayer = $Voix

var audio_streams = {}

#endregion

#region Initialisation et process

## Initialisation de la boîte, les boîtes sont invisibles au début
func _ready():
	if (!DialogBox) :
		DialogBox = $DialogBox/MarginContainer/HBoxContainer/Dialog
		NameBox = $NameBox/MarginContainer/VBoxContainer/Name
	container = self
	
	for name in characters_data :
		audio_streams[name] = load(characters_data[name]["audio"])
	
	hide_textbox()
	
	cooldown = Timer.new()
	cooldown.set_wait_time(0.1)
	cooldown.one_shot = true
	add_child(cooldown)


## Méthode appelée en permanence pour mettre à jour l'état de la boîte de texte (montrant petit à petit le texte
func _process(delta): 
	if container.visible:
		# Si la boîte n'est pas pleine, alors on la remplit jusqu'à ce qu'elle le soit
		if !FullDialogBox :
			DialogBox.visible_ratio +=  delta * vitesseTailleText
			# Bruit audio à jouer # 
			if DialogBox.visible_ratio >= 1 :
				FullDialogBox = true
				cooldown.start()
		else : if (audio.playing):
			audio.stop()
			


## Méthode permettant d'initialiser l'affichage des boîtes de dialogues
func show_textbox():
	# On repasse les box en visibles
	container.visible = true

## Bouton pressé
func _input(event) :
	# Vérification de la visibilité de Namebox : on passe au prochain dialogue seulement si la boîte est initialisée de base
	if event.is_action_pressed("interact") && container.visible == true && (cooldown.time_left <= 0):
		# Si la boîte est déjà pleine, alors on passe au dialogue suivant
		if FullDialogBox :
			emit_signal("show_next_dialogue")
		# Sinon, on accélère le texte jusqu'au bout direct
		else :
			DialogBox.visible_ratio = 1
			FullDialogBox = true
		
		cooldown.start()


#endregion

#region Changement texte

## Méthode gérant l'affichage du texte (remettant le ratio de visibilité à 0 et remplaçant le texte affiché)
func update_dialogue_display(new_dialogue_line):
	if container.visible:
		dialogue_line = new_dialogue_line
		# print("update dialogue pour ", dialogue_line['name'])
		
		DialogBox.visible_ratio = 0
		var charaName = name()
		if (NameBox) :
			NameBox.text = "[center][color=" + charaName + "]" + dialogue_line['name'] + "[/color]"
		DialogBox.text = content_align + dialogue_line['text']
		
		FullDialogBox = false
		
		vitesseTailleText = vitesseLecture * (100.0 / max(DialogBox.get_total_character_count(), 1))
		audio.stop()
		set_audio()
		audio.play()

## Méthode re-définissant des attributs locaux à partir du nom actuel
## Par exemple : l'audio joué, la couleur du texte, autres effets, ...
func name() -> String :
	var retour = "white"
	vitesseLecture = 0.847
	# On vérifie l'existence du nom dans la configuration des personnages
	if dialogue_line['name'] in characters_data:
		retour = characters_data[dialogue_line['name']]["color"]
		vitesseLecture = characters_data[dialogue_line['name']]["vitesseLecture"]
	
	if (!NameBox) :
		vitesseLecture = vitesseLecture / 3
	
	return retour

func set_audio() :
	if dialogue_line['name'] in characters_data:
		audio.stream = audio_streams.get(dialogue_line['name'])
	else:
		audio.stream = audio_streams.get("Neant")

#endregion

#region Fin Dialogue

## Cache la textbox entière et reset le texte
func hide_textbox() :
	audio.stop()
	if (NameBox) :
		NameBox.text = ""
	DialogBox.text =""
	DialogBox.visible_ratio = 0
	container.hide()
	emit_signal("dialogue_ended")


#endregion
