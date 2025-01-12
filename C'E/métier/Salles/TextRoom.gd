extends Control

@export var Musique : String = "res://Ressources/Sons/Musiques/01- Vide.mp3"
@export var sceneSuivante : String
## Variable permettant de savoir si la scène suivante est ingame ou non (savoir si on reste dans le Main ou si on passe à un autre noeud de type menu)
@export var sceneSuivanteIngame : bool = true
@export var lienText : String
@export var tempsFadeIn : float = 5.0
@export var tempsFadeOut : float = 5.0

@onready var label : Label = $Label
@onready var timer : Timer
var tween : Tween
var tweenFermeture : Tween


func _ready():
	get_node("/root/Main")._replace_music(Musique)
	
	label.modulate.a = 0
	load_menu()
	
	tween = create_tween()
	tween.tween_property(label,"modulate:a",1.0,tempsFadeIn)


func load_menu():
	var langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/" + lienText,FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$Label.text = texts[0]
		
		fichier.close()
	else:
		print("Erreur lors de la lecture du fichier texte : " + lienText)

func _input(event):
	if event.is_action_pressed("interact"):
		tween.kill()
		label.modulate.a = 1.0
		
		tweenFermeture = create_tween()
		tweenFermeture.tween_property(label,"modulate:a",0.0,tempsFadeOut)
		timer = Timer.new()
		timer.connect("timeout",_on_timer_timeout)
		add_child(timer)
		timer.start(5)
		get_tree().get_current_scene().fade_out(4.0)

func _on_timer_timeout():
	if (sceneSuivanteIngame) :
		get_tree().get_current_scene()._replace_scene(sceneSuivante,0)
	else :
		get_tree().change_scene_to_file(sceneSuivante)
