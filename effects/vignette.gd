@tool
class_name VignetteEffect
extends Node3D

@export_range(0.0, 1.0, 0.1) var radius = 1.0:
	set(value):
		radius = value
		if is_inside_tree():
			_update_radius()

@export_range(0.0, 0.1, 0.01) var fade = 0.05:
	set(value):
		fade = value
		if is_inside_tree():
			_update_fade()

func _update_radius():
	var material : ShaderMaterial = $MeshInstance3D.material_override
	if material:
		material.set_shader_parameter("radius", radius * sqrt(2));
	$MeshInstance3D.visible = radius < 1.0

func _update_fade():
	var material : ShaderMaterial = $MeshInstance3D.material_override
	if material:
		material.set_shader_parameter("fade", fade);

func _update_mesh():
	var vertices : PackedVector3Array
	var indices : PackedInt32Array
	
	var steps : int = 32
	
	vertices.resize(2 * steps)
	indices.resize(6 * steps)
	for i in steps:
		var v : Vector3 = Vector3.RIGHT.rotated(Vector3.FORWARD, TAU * i / steps)
		vertices[i] = v
		vertices[i + steps] = v * 2.0
		
		var off = i * 6
		var i2 = (i + 1) % steps
		indices[off + 0] = steps + i
		indices[off + 1] = steps + i2
		indices[off + 2] = i2
		indices[off + 3] = steps + i
		indices[off + 4] = i2
		indices[off + 5] = i

	var arr_mesh = ArrayMesh.new()
	var arr : Array
	arr.resize(ArrayMesh.ARRAY_MAX)
	arr[ArrayMesh.ARRAY_VERTEX] = vertices
	arr[ArrayMesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	$MeshInstance3D.mesh = arr_mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	# Leave this commented out unless we need to recreate our mesh.
	# _update_mesh()

	_update_radius()
	_update_fade()
