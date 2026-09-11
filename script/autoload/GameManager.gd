extends Node

signal game_started
signal game_over
signal score_updated(new_score: int)

const SAVE_PATH: String = "user://savegame.save"
const SCORE_PER_SECOND: float = 10.0

const BASE_SPEED: float = 600.0
const MAX_SPEED: float = 1400.0
const SPEED_INCREASE_PER_SECOND: float = 8.0

var current_speed: float = BASE_SPEED
var is_game_running: bool = false
var current_score: float = 0.0
var high_score: int = 0
var last_game_ended: bool = false

func _ready() -> void:
	_load_high_score()

func start_game() -> void:
	if is_game_running:
		return
	current_score = 0.0
	current_speed = BASE_SPEED
	is_game_running = true
	last_game_ended = false
	game_started.emit()
	score_updated.emit(0)

func end_game() -> void:
	is_game_running = false
	_check_and_save_high_score()
	last_game_ended = true
	game_over.emit()

func _process(delta: float) -> void:
	if not is_game_running:
		return

	# Incrementar Score y dificultad progresiva
	current_score += SCORE_PER_SECOND * delta
	current_speed = min(current_speed + SPEED_INCREASE_PER_SECOND * delta, MAX_SPEED)

	# Emitir el puntaje
	score_updated.emit(get_score_int())

func get_score_int() -> int:
	return int(current_score)

func _check_and_save_high_score() -> void:
	if get_score_int() > high_score:
		high_score = get_score_int()
		_save_high_score()

func _save_high_score() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.save(SAVE_PATH)

func _load_high_score() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: Error = config.load(SAVE_PATH)
	if error == OK:
		high_score = config.get_value("score", "high_score", 0)
	else:
		high_score = 0