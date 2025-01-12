extends "res://métier/Dialogues/interactable.gd"

@export var Musique : String = ""
## Variable du DialogueManager
var chemin : String

func _ready():
	get_node("/root/Main")._replace_music(Musique)
	load_event()

## Méthode permettant de lancer une série d'événements ("abstraite")
func load_event():
	pass

func start(chemin : String) :
	self.chemin = chemin
	interact()

func interact():
	emit_signal("start_dialogue",chemin,$TextBoxCinematic,self)

func _on_dialogue_ended():
	pass

## Méthode permettant d'attendre quelques temps avant un autre événement
func wait(seconds : float) :
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()
