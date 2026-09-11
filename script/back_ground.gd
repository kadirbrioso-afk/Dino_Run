extends ParallaxBackground

# El fondo se mueve más lento que el suelo para dar sensación de profundidad
@export var speed_scale: float = 0.4

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	scroll_offset.x -= GameManager.current_speed * speed_scale * delta