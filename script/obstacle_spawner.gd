extends Node2D

# Permite arrastrar la escena hasta el inspector
@export var bush_escene: PackedScene
@export var crow_escene: PackedScene

@export var min_spawn_time: float = 0.8
@export var max_spawn_time: float = 2.0

@onready var timer:Timer = $Timer
@onready var spawn_point1: Marker2D = $SpawnPointGround
@onready var spawn_point2: Marker2D = $SpawnPointAir

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	_start_next_timer()

func _process(_delta: float) -> void:
	pass

func _start_next_timer() -> void:
	# Elige tiempo aleatorio dentro del rango definido para que no sea predecible
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	timer.start()

func _on_timer_timeout() -> void:
	# Si el juego terminó detenemos el generador
	if not GameManager.is_game_running:
		return
	
	# Lanzaremos un dado que decida aleatoriamente entre los obstáculos
	var roll_dice:float = randf()
	
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
	
	# Instanciar el nodo
	var bush = bush_escene.instantiate() as Area2D
	
	# Asignar posición con Marker2D
	bush.global_position = spawn_point1.global_position
	
	# Añadir a la Escena Main para que aparezca como hijo 
	get_parent().add_child(bush)

func _spawn_crow() -> void:
	if crow_escene == null:
		return
	
	# Instanciar el nodo
	var crow = crow_escene.instantiate() as Area2D
	
	# Asignar posición con Marker2D
	crow.global_position = spawn_point2.global_position
	
	# Añadir a la Escena Main para que aparezca como hijo 
	get_parent().add_child(crow)
