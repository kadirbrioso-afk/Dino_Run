extends CharacterBody2D

@export var gravity: float = 4200.0
@export var jump_velocity: float = -1400.0
@export var duck_fall_multiplier: float = 2.0
@export var max_fall_speed: float = 2600.0
@export var coyote_time: float = 0.08
@export var jump_buffer_time: float = 0.12

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_standing: CollisionShape2D = $CollisionStanding
@onready var collision_ducking: CollisionShape2D = $CollisionDucking
@onready var hurt_box: Area2D = $HurtBox
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var duck_sound: AudioStreamPlayer = $DuckSound
@onready var hit_sound: AudioStreamPlayer = $HitSound

var is_ducking: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

func _ready() -> void:
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	GameManager.game_over.connect(_on_game_over)
	# Alinea al Dino con el piso en pantalla de inicio (antes de que corra la física)
	call_deferred("_snap_to_floor")

func _snap_to_floor() -> void:
	# Busca la colisión física del suelo para apoyar al Dino justo encima
	var main: Node = get_parent()
	if main == null or not main.has_node("Ground/FloorCollision/CollisionShape2D"):
		return
	var floor_shape: CollisionShape2D = main.get_node("Ground/FloorCollision/CollisionShape2D")
	var rect: RectangleShape2D = floor_shape.shape as RectangleShape2D
	if rect == null:
		return
	var floor_top: float = floor_shape.global_position.y - rect.size.y * 0.5
	# CollisionStanding ocupa desde su centro ± media altura
	position.y = floor_top - (collision_standing.position.y + (collision_standing.shape as RectangleShape2D).size.y * 0.5)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	var duck_pressed: bool = Input.is_action_pressed("duck")
	_set_ducking(duck_pressed and is_on_floor())

	# Aplicar gravedad con agachado en el aire (fast-fall) y límite de caída
	if is_on_floor():
		velocity.y = 0
	else:
		var fall_gravity: float = gravity
		if duck_pressed:
			fall_gravity *= duck_fall_multiplier
		velocity.y = min(velocity.y + fall_gravity * delta, max_fall_speed)

	# Coyote time y jump buffer para un salto más responsivo
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Saltar (solo estando de pie o dentro del margen de coyote, y sin agacharse)
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0 and not is_ducking:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		sprite.play("jump")
		jump_sound.play()

	move_and_slide()
	_update_animation()

func _set_ducking(should_duck: bool) -> void:
	if should_duck and not is_ducking:
		is_ducking = true
		duck_sound.play()
		collision_standing.set_deferred("disabled", true)
		collision_ducking.set_deferred("disabled", false)
	elif not should_duck and is_ducking:
		is_ducking = false
		collision_standing.set_deferred("disabled", false)
		collision_ducking.set_deferred("disabled", true)

func _update_animation() -> void:
	if is_ducking:
		sprite.play("duck")
	elif not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	else:
		sprite.play("run")

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	# Evita morir (y duplicar el sonido) si dos obstáculos golpean el mismo frame
	if not GameManager.is_game_running:
		return
	hit_sound.play()
	GameManager.end_game()

func _on_game_over() -> void:
	# Reproducir animacion de golpe (Game Over) y parpadeo de daño
	sprite.play("hurt")
	var tween := create_tween()
	tween.set_loops(2)
	tween.tween_property(sprite, "modulate", Color(1.9, 0.4, 0.4, 1), 0.07)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.07)