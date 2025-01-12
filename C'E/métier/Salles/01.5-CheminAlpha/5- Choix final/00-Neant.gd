extends "res://métier/Salles/RoomDialogTemplate.gd"

func load_event():
	await wait(3)
	start("01.5-CheminAlpha/05-3 Boucle/00-1Neant.json")
	await $TextBoxCinematic.dialogue_ended
	await wait(5)
	start("01.5-CheminAlpha/05-3 Boucle/00-2Neant.json")
	await $TextBoxCinematic.dialogue_ended
	await wait(2)
	
	get_tree().get_current_scene()._replace_sceneDialogue("res://métier/Salles/01.5-CheminAlpha/5- Choix final/00-FinSpirale.tscn")
