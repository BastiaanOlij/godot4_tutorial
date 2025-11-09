@tool
extends StaticBody3D

@export var size : Vector3 = Vector3(1.0, 1.0, 1.0):
	set(value):
		size = value
		if is_inside_tree():
			_update_size()

@export var color : Color = Color("aa6647"):
	set(value):
		color = value
		if is_inside_tree():
			_update_color()


func _update_size():
	$CollisionShape3D.shape.size = size
	$MeshInstance3D.mesh.size = size


func _update_color():
	var material : StandardMaterial3D = $MeshInstance3D.material_override
	if material:
		material.albedo_color = color


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_size()
	_update_color()
