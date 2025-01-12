extends "res://métier/Dialogues/text_box.gd"

func _ready():
	DialogBox = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Dialog
	NameBox = null
	content_align = "[center]"
	super._ready()
