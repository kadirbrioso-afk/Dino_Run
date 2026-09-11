extends Node2D

# Permite arrastrar la escena hasta el inspector
@export var bush_escene: PackedScene
@export var crow_escene: PackedScene

@export var min_spawn_time: float = 0.8
@export var max_spawn_time: float = 2.0
@export var crow_height_spread: float = 20.0

@onready var timer: Timer = $Timer
@onready var spawn_point_ground: Marker2D = $SpawnPointGround
@onready var spawn_point_air: Marker2D = $SpawnPointAir

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	GameManager.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	# Reinicia la cuenta de obstáculos al empezar una nueva partida
	timer.stop()
	_start_next_timer()

func _start_next_timer() -> void:
	# Elige tiempo aleatorio dentro del rango definido para que no sea predecible
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	timer.start()

func _on_timer_timeout() -> void:
	# Si el juego terminó detenemos el generador
	if not GameManager.is_game_running:
		return

	# Lanzaremos un dado que decida aleatoriamente entre los obstáculos
	var roll_dice: float = randf()

	# 60% Probabilidad Arbusto(bush) , 40% Probabilidad de Cuervo(Crow)
	if roll_dice < 0.6:
		_spawn_bush()
	else:
		_spawn_crow()

	# Luego de tomar la decisión y generar, iniciar nuevo Timer
	_start_next_timer()

func _spawn_bush() -> void:
	if bush_escene == null:
		return

	var bush: Area2D = bush_escene.instantiate()
	bush.global_position = spawn_point_ground.global_position
	get_parent().add_child(bush)

func _spawn_crow() -> void:
	if crow_escene == null:
		return

	var crow: Area2D = crow_escene.instantiate()
	# Pequeña variación hacia arriba para evitar patrones repetitivos
	crow.global_position = spawn_point_air.global_position + Vector2(0, -randf() * crow_height_spread)
	get_parent().add_child(crow)
