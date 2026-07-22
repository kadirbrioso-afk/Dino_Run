extends Node

# Constantes de Inicio
const DINO_START_POS := Vector2i(100, 470)
const CAM_START_POS := Vector2i(640, 360)

# Variables
var score: int
var speed: float
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
var screen_size = Vector2i()

func _ready() -> void:
	screen_size = get_window().size
	new_game()

func new_game():
	# Reset Variables
	score = 0
	# Reset de Nodos
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
func _process(delta: float) -> void:
	speed = START_SPEED
	
	# Mover Dino y Cámara
	$Dino.position.x += speed
	$Camera2D.position.x += speed
	
	# Actualizar Score
	score += speed
	
	# Actualizar Posicion del Suelo
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x
