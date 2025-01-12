extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("GAME OVER")
	await $MessageTimer.timeout 
	
	$Message.text="ET ON REPART DE 0, HOP HOP"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout #On crée un timer temporaire
	$StartButton.show()
	

func update_score(score):
	$ScoreLabel.text = str(score) # Le texte affichant le score prend la valeur string du score


func _on_start_button_pressed():
	$StartButton.hide() # On enlève le bouton pour recommencer
	start_game.emit()


func _on_message_timer_timeout():
	$Message.hide()
