extends Node2D

func _ready() -> void:
	# Al recargar la escena (o al arrancar) volvemos a la pantalla de inicio
	get_tree().paused = false
	GameManager.last_game_ended = false

func _unhandled_input(_event: InputEvent) -> void:
	if not GameManager.is_game_running and Input.is_action_just_pressed("restart"):
		if GameManager.last_game_ended:
			# Tras un Game Over, recarga la escena completa
			get_tree().reload_current_scene()
		else:
			# En la pantalla de inicio, Enter arranca la partida
			GameManager.start_game()