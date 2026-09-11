extends Sprite2D

@export var folder_path: String = "res://assets/sprites/obstacles/Pixel Art Bush Pack/Bush 2/"

func _ready() -> void:
	_randomize_variant()

# Cambia el color del arbusto al azar entre las variantes de su carpeta
func _randomize_variant() -> void:
	var files: PackedStringArray = DirAccess.get_files_at(folder_path)
	var pngs: PackedStringArray = []
	for file_name in files:
		if file_name.ends_with(".png"):
			pngs.append(file_name)
	if pngs.is_empty():
		return
	var new_texture: Texture2D = load(folder_path + pngs[randi() % pngs.size()])
	if new_texture != null:
		texture = new_texture