extends "res://métier/Salles/RoomDialogTemplate.gd"


func _ready():
	Save.initialisation_temp_save()
	super._ready()

func load_event():
	await wait(3)
	start("01.5-CheminAlpha/05-1 Fin Spirale/21-1ChrisRespire.json")
	await $TextBoxCinematic.dialogue_ended
	await wait(4)
	start("01.5-CheminAlpha/05-1 Fin Spirale/21-2ChrisRespire.json")
	await $TextBoxCinematic.dialogue_ended
	await wait(2)
	
	get_tree().get_current_scene()._replace_scene("res://métier/Salles/01.5-CheminAlpha/5- Choix final/13-BoucleFinale1.tscn",0,true)
