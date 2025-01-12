extends Area2D

@export var scene_suivante : String
@export var index_point_entree : int 
@export var scene_suivante_dialogue : bool

## Si le joueur atteint la sortie, on le fait passer dans la salle suivante
func _changeRoom():
	if (scene_suivante_dialogue) :
		get_tree().get_current_scene()._replace_sceneDialogue(scene_suivante)
	else :
		get_tree().get_current_scene()._replace_scene(scene_suivante,index_point_entree)
