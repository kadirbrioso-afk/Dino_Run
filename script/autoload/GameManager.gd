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
var new_record: bool = false

var _last_emitted_score: int = -1

func _ready() -> void:
	_load_high_score()

func start_game() -> void:
	if is_game_running:
		return
	current_score = 0.0
	current_speed = BASE_SPEED
	is_game_running = true
	last_game_ended = false
	new_record = false
	_last_emitted_score = 0
	game_started.emit()
	score_updated.emit(0)

func end_game() -> void:
	if not is_game_running:
		return
	is_game_running = false
	new_record = get_score_int() > high_score
	_check_and_save_high_score()
	last_game_ended = true
	game_over.emit()

func _process(delta: float) -> void:
	if not is_game_running:
		return

	# Incrementar Score y dificultad progresiva
	current_score += SCORE_PER_SECOND * delta
	current_speed = min(current_speed + SPEED_INCREASE_PER_SECOND * delta, MAX_SPEED)

	# Emitir el puntaje solo cuando cambia el entero visible
	var score_int: int = get_score_int()
	if score_int != _last_emitted_score:
		_last_emitted_score = score_int
		score_updated.emit(score_int)

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