@tool
class_name FadeEffect
extends Node3D

@export_range(0.0, 1.0, 0.01) var fade : float = 0.0:
	set(value):
		fade = value
		if is_inside_tree():
			_update_fade() 

func _update_fade():
	if fade == 0.0:
		$MeshInstance3D.visible = false
	else:
		$MeshInstance3D.visible = true
		var material : ShaderMaterial = $MeshInstance3D.material_override
		if material:
			material.set_shader_parameter("alpha", fade)

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_fade()
