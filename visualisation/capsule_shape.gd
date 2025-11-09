@tool
extends MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var collision_shape : CollisionShape3D = get_parent()
	if not collision_shape:
		return

	var capsule_shape : CapsuleShape3D = collision_shape.shape
	if not capsule_shape:
		return

	mesh.height = capsule_shape.height
	mesh.radius = capsule_shape.radius
