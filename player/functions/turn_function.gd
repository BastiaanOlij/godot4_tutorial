class_name TurnFunction
extends Node3D

## Our turn speed
@export_range(1.0, 180.0, 0.1, "suffix:°/s", "radians_as_degrees") var speed : float = deg_to_rad(45.0)

## Our step angle, set this to zero to get smooth turning
@export_range(0.0, 45.0, 0.1, "suffix:°", "radians_as_degrees") var step_angle: float = 0.0

## Link to our vignette
@export var vignette : VignetteEffect

## Our vignette strength
@export_range(0.0, 1.0, 0.1) var vignette_strength = 0.3

var controller : XRController3D
var character_body : CharacterBody3D

var rotation_angle : float = 0.0

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

	var input : float = -controller.get_vector2("movement").x

	rotation_angle += input * speed * delta
	if abs(rotation_angle) > step_angle:
		var new_basis : Basis = character_body.transform.basis
		new_basis = new_basis.rotated(new_basis.y, rotation_angle)
		character_body.basis = new_basis
		rotation_angle = 0.0

	if vignette:
		vignette.radius = 1.0 - abs(input) * vignette_strength
