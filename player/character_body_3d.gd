@tool
extends CharacterBody3D

## Camera for our first person head
@export var camera : Camera3D

## Our upper body height
@export var upper_body_height : float = 1.0

## Radius for our body
@export var upper_body_radius : float = 0.3

## Head offset for our upper body
@export var upper_body_head_offset : float = 0.2

## PID controller for standing
@export_group("PID", "pid_")
@export_range(0.0, 10.0, 0.01) var pid_proportional_gain : float = 0.8
@export_range(0.0, 10.0, 0.01) var pid_integral_gain : float = 0.1
@export_range(0.0, 10.0, 0.01) var pid_integral_saturation : float = 1.0
@export_range(0.0, 10.0, 0.01) var pid_derivative_gain : float = 0.2

@onready var body_collision : CollisionShape3D = $BodyCollisionShape
@onready var body_shape : CapsuleShape3D = $BodyCollisionShape.shape
@onready var raycast : RayCast3D = $FloorRayCast

# PID tracking
var value_last : float = 0.0
var derivative_initialised : bool = false
var integral_stored : float = 0.0

func _calculate_pid(delta : float, current_value : float, target_value : float) -> float:
	var error : float = current_value - target_value

	# Calculate P term
	var p : float = pid_proportional_gain * error

	# Calculate I term
	integral_stored = clamp(integral_stored + (error * delta), -pid_integral_saturation, pid_integral_saturation)
	var i : float = pid_integral_gain * integral_stored

	# Calculate D term
	var value_rate_of_change : float = (current_value - value_last) / delta
	value_last = current_value

	var d : float = 0.0
	if derivative_initialised:
		d = pid_derivative_gain * value_rate_of_change
	else:
		derivative_initialised = true

	return p + i + d


func _process(_delta):
	if camera:
		# Get our camera transform in our character body's local space
		var camera_transform : Transform3D = global_transform.inverse() * camera.global_transform

		var player_height : float = camera_transform.origin.y + upper_body_head_offset

		# Position our body collision
		body_collision.transform.origin.y = player_height - upper_body_height * 0.5
		if body_shape.radius != upper_body_radius:
			body_shape.radius = upper_body_radius
		if body_shape.height != upper_body_height:
			body_shape.height = upper_body_height

		# Position our raycast
		raycast.transform.origin.y = player_height - upper_body_height
		raycast.target_position.y = -raycast.transform.origin.y


func _physics_process(delta):
	# Do not run this in editor!
	if Engine.is_editor_hint():
		return

	# Add the gravity.
	velocity += get_gravity() * delta

	# Apply our standing up logic
	if raycast.is_colliding():
		# Get our collision point in the local space of our character
		var point = global_transform.inverse() * raycast.get_collision_point()
		var pid_factor : float = _calculate_pid(delta, point.y, 0.0)
		velocity += global_basis.y * pid_factor

	move_and_slide()
