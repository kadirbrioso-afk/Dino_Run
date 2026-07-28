extends Node

signal game_started
signal game_over
signal score_updated(new_score: int)

const BASE_SPEED: float = 800.0 
const MAX_SPEED: float = 1400.0
const SPEED_INCREASE: float = 8.0

var current_speed: float = BASE_SPEED
var is_game_running: bool = false
var current_score: float = 0.0

func start_game() -> void:
	current_score = 0
	current_speed = BASE_SPEED
	is_game_running = true
	game_started.emit()

func end_game() -> void:
	is_game_running = false
	game_over.emit()

func _process(delta: float) -> void:
	if not is_game_running:
		return
		
	# Incrementar Score
	current_score += 10.0 * delta
	current_speed = min(current_speed + SPEED_INCREASE * delta, MAX_SPEED)
	
	# Emitir el puntaje
	score_updated.emit(int(current_score)) 
