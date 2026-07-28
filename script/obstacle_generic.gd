extends Area2D

@export var speed: float = 600.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	notifier.screen_exited.connect(_on_screen_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta
	
func _on_screen_exited() -> void:
	queue_free()
