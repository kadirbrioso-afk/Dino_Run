extends Node2D

func _ready() -> void:
	get_tree().paused = false
	# Tras un Game Over, reinicia directamente a una partida nueva
	if GameManager.last_game_ended:
		GameManager.start_game()

func _unhandled_input(_event: InputEvent) -> void:
	if GameManager.is_game_running:
		return

	if Input.is_action_just_pressed("restart"):
		if GameManager.last_game_ended:
			# Tras un Game Over, recarga la escena (que arranca directo)
			get_tree().reload_current_scene()
		else:
			# En la pantalla de inicio, Enter arranca la partida
			GameManager.start_game()
	elif not GameManager.last_game_ended and Input.is_action_just_pressed("jump"):
		# Espacio / Flecha arriba también arrancan desde la pantalla de inicio
		GameManager.start_game()