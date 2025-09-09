extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var material : StandardMaterial3D = $Display/Screen.material_override
	if material:
		material.albedo_texture = get_viewport().get_texture()
