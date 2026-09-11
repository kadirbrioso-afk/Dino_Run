extends Area2D

@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	notifier.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return
	position.x -= GameManager.current_speed * delta

func _on_screen_exited() -> void:
	queue_free()
