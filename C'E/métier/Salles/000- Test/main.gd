extends Node

@export var mob_scene: PackedScene # On précise la scène du mob
var score



# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player_Chris_combat.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("LA SAUCE ARRIVE !")
	


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout():
	score +=1
	$HUD.update_score(score)

func _on_mob_timer_timeout(): # Création des monstres
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation") # On récupère la position d'apparition
	mob_spawn_location.progress_ratio = randf() # On prend un point au hasard 
	
	var direction  = mob_spawn_location.rotation + PI / 2; # Direction perpendiculaire à l'apparition de l'ennemi
	
	mob.position = mob_spawn_location.position;
	
	var velocity = Vector2(randf_range(350.0,500.0), 0.0) # Vitesse du projectile
	mob.linear_velocity = velocity.rotated(direction) # Direction du mob
	
	add_child(mob)
