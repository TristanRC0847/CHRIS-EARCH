extends Area2D

@export var Musique : String = "res://Ressources/Sons/Musiques/01- Vide.mp3"
@export var SaveRoom : bool = false

## Called when the node enters the scene tree for the first time.
func _ready():
	# Place le joueur par défaut au point de départ
	$Player_Chris.position = $PointsEntree/Point_1.position
	get_node("/root/Main")._replace_music(Musique)
	
	# Vérification que la dernière sauvegarde n'est pas cette salle aussi
	if (SaveRoom) && (Save.get_current_scene() != self.scene_file_path) :
		get_node("/root/Main").save_game(self.scene_file_path)
 

## Méthode permettant d'initialiser la position de Chris sur la carte
func setChris(index_point_entree : int):
	
	if index_point_entree < $PointsEntree.get_child_count():
		
		var point : Marker2D = $PointsEntree.get_child(index_point_entree) 
		# Vérification que le point existe bien, sinon on prendra simplement le premier
		if point :
			$Player_Chris.position = point.position
		else:
			print("Le point entré n'existe pas")
	else:
		print("L'index du point d'entrée demandé est en hors-limite")
