extends CharacterBody2D

@export var gravity: float = 4200.0
@export var jump_velocity: float = -1400.0
@export var duck_speed_multiplier: float = 1.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_standing: CollisionShape2D = $CollisionStanding
@onready var collision_ducking: CollisionShape2D = $CollisionDucking

var is_ducking: bool = false

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Saltar (Solo si esta en el suelo)
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		sprite.play("jump")
		$jump_sound.play()

	# Agacharse 
	if Input.is_action_pressed("duck") and is_on_floor():
		_start_duck()
		$duck_sound.play()
	else:
		_stop_duck()
	
	move_and_slide()
	_update_animation()
	
func _start_duck():
	if is_ducking:
		return
	is_ducking = true
	collision_standing.set_deferred("disabled", true)
	collision_ducking.set_deferred("disabled", false)
	
func _stop_duck():
	if not is_ducking:
		return
	is_ducking = false
	collision_standing.set_deferred("disabled", false)
	collision_ducking.set_deferred("disabled", true)
	
func _update_animation():
	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	elif is_ducking:
		sprite.play("duck")
	else:
		sprite.play("run")
		
	
