class_name DirectMovementFunction
extends Node3D

## Maximum speed in forward and/or sideways movement
@export var max_speed : Vector2 = Vector2(3.0, 5.0)

## Movement lerp factor
@export_range(1.0, 10.0, 0.1) var lerp_factor : float = 3.0

var controller : XRController3D
var character_body : CharacterBody3D

func _enter_tree():
	var parent : Node = get_parent()
	while parent:
		if not controller and parent is XRController3D:
			controller = parent
		elif not character_body and parent is CharacterBody3D:
			character_body = parent
		
		parent = parent.get_parent()



func _physics_process(delta):
	if not controller:
		return
	if not character_body:
		return

	var input : Vector2 = controller.get_vector2("movement") * Vector2(1.0, -1.0)

	# Deconstruct velocity for each direction
	var forward_velocity = character_body.velocity.project(character_body.global_basis.z)
	var sideways_velocity = character_body.velocity.project(character_body.global_basis.x)
	var vertical_velocity = character_body.velocity.project(character_body.global_basis.y)

	# Desired velocities:
	var forward = character_body.global_basis.z * input.y * max_speed.y
	var sideways = character_body.global_basis.x * input.x * max_speed.x

	# Construct our new velocity
	character_body.velocity = vertical_velocity \
		+ forward_velocity.lerp(forward, delta * lerp_factor) \
		+ sideways_velocity.lerp(sideways, delta * lerp_factor)
