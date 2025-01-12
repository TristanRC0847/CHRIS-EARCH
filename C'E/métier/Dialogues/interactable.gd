extends Node

## Signal permettant de commencer un dialogue
signal start_dialogue(chemin_dialogue : String, textBox : CanvasLayer, objet : Node)

## Méthode permettant d'interagir, redéfinies dans les classes implémentant interactable
func interact():
	pass
