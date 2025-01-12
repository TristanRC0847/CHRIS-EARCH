extends "res://métier/Salles/RoomDialogTemplate.gd"


func load_event():
	await wait(3)
	start("01- Introduction/01-Entree/00-Introduction.json")
	await $TextBoxCinematic.dialogue_ended
	
	get_tree().get_current_scene()._replace_scene("res://métier/Salles/01- Introduction/IntroMap-01.tscn",0,true)
