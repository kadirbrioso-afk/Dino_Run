extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.start_game()


func _unhandled_input(_event: InputEvent) -> void:
	if not GameManager.is_game_running and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
