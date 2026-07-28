extends Node2D

@export var scroll_speed: float = 500.0
@onready var segments: Array[Sprite2D] = [$GroundSegmentA, $GroundSegmentB]

var segment_width: float

func _ready() -> void:
	segment_width = segments[0].texture.get_width()

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return

	for segment in segments:
		segment.position.x -= scroll_speed * delta

	# Reposicionar el segmento que salió de pantalla al final del otro
	for segment in segments:
		if segment.position.x <= -segment_width:
			var other_segment: Sprite2D = _get_other_segment(segment)
			segment.position.x = other_segment.position.x + segment_width

func _get_other_segment(current: Sprite2D) -> Sprite2D:
	return segments[1] if current == segments[0] else segments[0]
