extends "res://métier/SallesElements/Objets/objet.gd"

@export var chapitre : Chapitres.chaps
@export var eventID : String

func _ready():
	super._ready()
	
	# Si l'événement a déjà eu lieu, on le supprime d'emblée
	if (Save.is_event_completed(Chapitres.chaps.keys()[chapitre],eventID)):
		queue_free()
	

func _on_dialogue_ended():
	super._on_dialogue_ended()
	
	Save.save_event(Chapitres.chaps.keys()[chapitre],eventID)
	
	queue_free()
