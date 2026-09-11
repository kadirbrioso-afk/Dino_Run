extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var start_screen: Control = $StartScreen
@onready var game_over_screen: Control = $GameOverScreen
@onready var final_score_label: Label = $GameOverScreen/CenterContainer/VBoxContainer/FinalScoreLabel
@onready var new_record_label: Label = $GameOverScreen/CenterContainer/VBoxContainer/NewRecordLabel
@onready var start_button: Button = $StartScreen/CenterContainer/VBoxContainer/StartButton
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound

func _ready() -> void:
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	start_button.pressed.connect(_on_start_button_pressed)

	score_label.text = "0000"
	high_score_label.text = "HI %04d" % GameManager.high_score
	new_record_label.visible = false
	start_screen.visible = true
	game_over_screen.visible = false

func _on_score_updated(new_score: int) -> void:
	score_label.text = "%04d" % new_score
	# El high score se actualiza en vivo cuando se supera el récord
	if new_score > GameManager.high_score:
		high_score_label.text = "HI %04d" % new_score

func _on_game_started() -> void:
	start_screen.visible = false
	game_over_screen.visible = false
	new_record_label.visible = false
	# Suelta el foco del botón para que Enter no lo reactive durante la partida
	start_button.release_focus()

func _on_game_over() -> void:
	game_over_screen.visible = true
	final_score_label.text = "Score: %04d" % GameManager.get_score_int()
	high_score_label.text = "HI %04d" % GameManager.high_score
	new_record_label.visible = GameManager.new_record
	game_over_sound.play()

func _on_start_button_pressed() -> void:
	GameManager.start_game()