extends Node2D

## Musique jouée actuellement en background
@export var currentMusic : String = ""
@export var musicVolume : float = 1.0
var current_fade_tween : Tween = null

signal fade_scene_completed

#region Initialisation

## Initialisation, rajoute la première scène du jeu
func _ready() :
	var scene = Save.get_current_scene()
	var firstScene = load(scene)
	var newScene = firstScene.instantiate()
	$Game/SceneHolder.add_child(newScene)
	set_dialogue_signals(newScene)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$PauseCanvasLayer/MenuPause/MarginContainer/VBoxContainer/Continuer.connect("pressed",pause)
	
	$Transition.visible = false
	
	load_menu()

func load_menu():
	var langue = Settings.get_code_language(Settings.settings.get("General",{}).get("language",0))
	var fichier = FileAccess.open("res://Ressources/Textes/" + langue + "/Menus/main.json",FileAccess.READ)
	if fichier:
		var texts = JSON.parse_string(fichier.get_as_text())
		
		$Sauvegarde/Label.text = texts.get("sauvegarde")
		
		fichier.close()
	else:
		print("Erreur lors de la lecture du fichier texte de Main")

#endregion 

#region Pause Menu

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
		$PauseCanvasLayer/MenuPause.pause()
		if ($PauseCanvasLayer/MenuPause.pauseMode):
			$Game.process_mode = Node.PROCESS_MODE_DISABLED
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			$Game.process_mode = Node.PROCESS_MODE_ALWAYS
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#endregion

#region Sauvegarde

## Méthode permettant de sauvegarder le jeu
func save_game(current_room : String) :
	$Game.process_mode = Node.PROCESS_MODE_DISABLED
	
	$Sauvegarde/Label.visible = true
	$Sauvegarde/Label.modulate.a = 1.0
	
	await Save.save(current_room)
	
	$Game.process_mode = Node.PROCESS_MODE_ALWAYS
	
	create_tween().tween_callback(fade_out_label.bind($Sauvegarde/Label)).set_delay(2.0)
	

## Méthode permettant de faire disparaître un label en fondu
func fade_out_label(label : Label) :
	var tween = create_tween()
	tween.tween_property(label,"modulate:a",0.0,1.0)
	await tween.finished
	label.visible = false

#endregion

#region SceneManager


## Ajoute une scène à la scène actuelle (un ennemi, ...)
func _add_scene(newScene) :
	$Game/SceneHolder.add_child(newScene.instantiate())

## Remplace la scène actuelle par une autre (passage d'une salle à une autre)
func _replace_scene(newScene : String, index_point_entree : int, fondu : bool = false) :
	call_deferred("_replace_scene_deferred", newScene, index_point_entree, fondu)

func _replace_sceneDialogue(newScene : String, fondu : bool = false) :
	call_deferred("_replace_sceneDialog_deferred", newScene, fondu)

## Remplace la scène actuelle par une autre (passage d'une salle à une autre)
## (Appelé en différencié pour éviter des soucis de moteur)
func _replace_scene_deferred(newScene : String, index_point_entree : int, fondu : bool) :
	if (fondu):
		$Game/SceneHolder.process_mode = Node.PROCESS_MODE_DISABLED
		_fade_to_black()
		await fade_scene_completed
	
	for node in $Game/SceneHolder.get_children() :
		$Game/SceneHolder.remove_child(node)
	var newSceneLoaded = load(newScene).instantiate()
	$Game/SceneHolder.add_child(newSceneLoaded)
	set_dialogue_signals(newSceneLoaded)
	
	
	
	newSceneLoaded.setChris(index_point_entree)
	
	if (fondu):
		_fade_from_black()
		$Game/SceneHolder.process_mode = Node.PROCESS_MODE_ALWAYS
		await fade_scene_completed


func _replace_sceneDialog_deferred(newScene : String, fondu : bool) :
	if (fondu):
		$Game/SceneHolder.process_mode = Node.PROCESS_MODE_DISABLED
		_fade_to_black()
		await fade_scene_completed
	
	for node in $Game/SceneHolder.get_children() :
		$Game/SceneHolder.remove_child(node)
	var newSceneLoaded = load(newScene).instantiate()
	$Game/SceneHolder.add_child(newSceneLoaded)
	set_dialogue_signals(newSceneLoaded)
	
	if (fondu):
		_fade_from_black()
		$Game/SceneHolder.process_mode = Node.PROCESS_MODE_ALWAYS
		await fade_scene_completed

func set_dialogue_signals(newSceneLoaded : Node):
	
	if (newSceneLoaded.has_node("Objets")) :
		# Gestion des dialogues pour une scene de jeu
		$Game/DialogueManager.connect_interactables(newSceneLoaded.get_node("Objets"))
		$Game/DialogueManager.connect_interactables(newSceneLoaded.get_node("Evenements"))
		$Game/DialogueManager.setplayer(newSceneLoaded.get_node("Player_Chris"))
	else :
		# Gestion pour les scene cinématiques
		$Game/DialogueManager.connect_interactables(newSceneLoaded)
		$Game/DialogueManager.setplayer(null)
	

## Méthode permettant de passer en fondu une scène (passage de normal au noir)
func _fade_to_black():
	$Transition.visible = true
	var tween = create_tween()
	tween.tween_property($Transition/ColorRect,"color:a",1.0,3.0)
	await tween.finished
	emit_signal("fade_scene_completed")

## Méthode permettant de passer en fondu une scène (passage de noir à normal)
func _fade_from_black():
	var tween = create_tween()
	tween.tween_property($Transition/ColorRect,"color:a",0.0,4.0)
	await tween.finished
	emit_signal("fade_scene_completed")
	$Transition.visible = false

#endregion

#region Musiques

## Remplace la musique actuelle par une autre si elle est différente
## (paramètre passé pour jouer ou non la musique directement)
func _replace_music(music : String, play : bool = true) :
	if (music != currentMusic || currentMusic == "") :
		currentMusic = music
		if (music == "") :
			fade_out(10.0)
		else :
			# On arrête le fade s'il y en a un :
			if (current_fade_tween != null) :
				current_fade_tween.kill()
			
			$Game/MusicPlayer.stream = load(currentMusic)
			$Game/MusicPlayer.volume_db = 0
			if (play):
				$Game/MusicPlayer.play()

## Met la musique actuelle sur pause
func _pause_music():
	$Game/MusicPlayer.stream_paused = true

## Reprends la musique actuelle
func _resume_music():
	$Game/MusicPlayer.stream_paused = false

## Modifie le volume de la musique
func set_volume(volume: float):
	musicVolume = clamp(volume,0.0,1.0)
	$Game/MusicPlayer.volume_db = linear_to_db(musicVolume)

## Fais progressivement venir la musique
func fade_in(duree : float):
	$Game/MusicPlayer.volume_db = -80
	$Game/MusicPlayer.play()
	current_fade_tween = create_tween()
	current_fade_tween.tween_property($Game/MusicPlayer,"volume_db",linear_to_db(musicVolume),duree)

## Arrête progressivement la musique
func fade_out(duree : float):
	current_fade_tween = create_tween()
	current_fade_tween.tween_property($Game/MusicPlayer,"volume_db",-80,duree)
	current_fade_tween.tween_callback($Game/MusicPlayer.stop)

#endregion
