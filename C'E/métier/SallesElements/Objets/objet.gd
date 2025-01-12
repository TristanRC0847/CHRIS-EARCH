extends "res://métier/Dialogues/interactable.gd"

# Liste des dialogues de l'objet
@export var dialogue_ids: Array[String] = []
var dialogue_index = 0

@export var group : String 
@export var direction : TypeDirection.Direction = TypeDirection.Direction.NONE

func _ready():
	add_to_group(group)

func interact():
	if (dialogue_ids.size() > 0):
		var dialogue_actuel = dialogue_ids[dialogue_index]
		emit_signal("start_dialogue",dialogue_actuel,$TextBox,self)

func _on_dialogue_ended():
	# On restera toujours sur le dernier dialogue à la fin, donc on reste sur une boucle
	if (dialogue_index < dialogue_ids.size() -1):
		dialogue_index+=1



