extends ParallaxBackground

@export var scroll_speed: float = 300.0

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return
	
	scroll_offset.x -= scroll_speed * delta
