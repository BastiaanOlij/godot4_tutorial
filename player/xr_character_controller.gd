@tool
class_name XRCharacterController
extends XROrigin3D

## XRCharacterController applies the physical movement of the player
## to it's parent CharacterBody3D node.

## How far away before we start fading to black
@export_range(0.01, 1.0, 0.01, "suffix:m") var max_distance = 0.8

## Distance over which we fade out
@export_range(0.01, 1.0, 0.01, "suffix:m") var fade_distance = 0.2

## Our fade effect object
@export var fade_effect : FadeEffect

## Size of our head
@export_range(0.05, 0.5, 0.01) var head_radius = 0.15

## Our head height
@export_range(0.5, 2.0, 0.01) var head_height = 1.6

## Auto calibrate height
@export var auto_calibrate_height : bool = true

var _shape_query : PhysicsShapeQueryParameters3D
var _calibrated_height : bool = false
var _height_adjustment : float = 0.0

## Calibrate our users height
func calibrate_height() -> void:
	var head_tracker : XRPositionalTracker = XRServer.get_tracker("head")
	if not head_tracker:
		return

	var head_pose : XRPose = head_tracker.get_pose("default")
	if not head_pose:
		return

	var head_transform = head_pose.get_adjusted_transform()
	var tracked_head_height = head_transform.origin.y
	_height_adjustment = head_height - tracked_head_height

	transform.origin.y = _height_adjustment
	_calibrated_height = true


func _ready():
	# Do not run when in editor!
	if Engine.is_editor_hint():
		return

	# Do not run if we're not a child of a CharacterBody3D node.
	var character_body : CharacterBody3D = get_parent()
	if not character_body:
		return

	var shape : SphereShape3D = SphereShape3D.new()
	shape.radius = head_radius

	_shape_query = PhysicsShapeQueryParameters3D.new()
	_shape_query.collision_mask = character_body.collision_mask
	_shape_query.exclude = [ character_body.get_rid() ]
	_shape_query.shape = shape

	if auto_calibrate_height:
		calibrate_height()

	var xr_interface : OpenXRInterface = XRServer.find_interface("OpenXR")
	if xr_interface:
		xr_interface.session_visible.connect(_on_session_visible)
		xr_interface.pose_recentered.connect(_on_pose_recenter)


func _on_session_visible():
	if auto_calibrate_height and not _calibrated_height:
		calibrate_height()


func _on_pose_recenter():
	if auto_calibrate_height:
		calibrate_height()


# Provide our configuration warnings
func _get_configuration_warnings():
	var warnings : PackedStringArray

	var parent = get_parent()
	if not parent or not parent is CharacterBody3D:
		warnings.push_back("This node must be a child of a CharacterBody3D node.")

	var camera = get_node_or_null("XRCamera3D")
	if not camera or not camera is XRCamera3D:
		warnings.push_back("This node must have an XRCamera3D child node.")

	return warnings


# Physics process run every physics tick
func _physics_process(_delta):
	# Do not run when in editor!
	if Engine.is_editor_hint():
		return

	# Do not run if we're not a child of a CharacterBody3D node.
	var character_body : CharacterBody3D = get_parent()
	if not character_body:
		return

	# Do not run if we don't have an XR camera.
	var camera : XRCamera3D = get_node_or_null("XRCamera3D")
	if not camera:
		return

	################################
	# Handle movement

	# Where is our camera in the local space of our character body?
	var camera_transform = transform * camera.transform

	# Determine our new position
	var new_position : Vector3 = camera_transform.origin * Vector3(1.0, 0.0, 1.0)

	# Now get this in world space
	new_position = character_body.global_transform * new_position

	# Move our character body
	var original_position = character_body.global_position
	character_body.move_and_collide(new_position - original_position)

	# Check our actual movement
	var delta_movement = character_body.global_position - original_position

	# Convert to local orientation
	delta_movement = character_body.global_basis.inverse() * delta_movement

	# Move our origin in the opposite direction
	position -= delta_movement

	################################
	# Handle rotation

	# We want to determine our forward vector
	var forward = camera_transform.basis.z * Vector3(1.0, 0.0, 1.0)

	# Create a rotation transform out of this
	camera_transform.origin = Vector3()
	var rotation_transform = camera_transform.looking_at(forward, Vector3.UP, true)

	# Apply this transform to our character body
	character_body.transform.basis = rotation_transform.basis * character_body.transform.basis

	# apply inverse to our origin
	transform = rotation_transform.inverse() * transform

	################################
	# Handle fade

	# Check if our head collides if moved to the camera position
	var space = PhysicsServer3D.body_get_space(character_body.get_rid())
	var state = PhysicsServer3D.space_get_direct_state(space)

	var t : Transform3D = Transform3D()
	t.origin = character_body.global_transform * Vector3(0.0, head_height, 0.0)
	_shape_query.transform = t
	_shape_query.motion = camera.global_position - t.origin

	var collision = state.cast_motion(_shape_query)
	var is_colliding : bool = not collision.is_empty() and collision[0] < 1.0

	# Calculate how far away we are from our target location
	var distance = (character_body.global_position - new_position).length()

	var fade = clamp((distance - max_distance) / fade_distance, 0.0, 1.0)
	if fade_effect:
		fade_effect.fade = 1.0 if is_colliding else fade
