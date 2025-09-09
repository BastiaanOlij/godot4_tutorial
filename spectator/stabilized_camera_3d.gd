extends Camera3D

## XR Camera we're stabilizing
@export var xr_camera : XRCamera3D

## Smoothing delay
@export_range(0.01, 1.0, 0.01, "suffix:s") var smooth_delay : float = 0.1

var prev_transform : Transform3D = Transform3D()

# Called when the node enters the scene tree for the first time.
func _ready():
	if xr_camera:
		prev_transform = xr_camera.transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If our camera is not setup, we can't do anything.
	if not xr_camera:
		return

	# We smooth out the camera 
	var adjusted_transform : Transform3D = xr_camera.transform

	# Remove pitch from camera.
	adjusted_transform.basis = Basis.looking_at(adjusted_transform.basis.z, Vector3.UP, true)

	# We (s)lerp our physical camera movement to smooth things out
	adjusted_transform.basis = prev_transform.basis.slerp(adjusted_transform.basis, delta / smooth_delay)
	adjusted_transform.origin = prev_transform.origin.lerp(adjusted_transform.origin, delta / smooth_delay)

	# Update our first person view.
	global_transform = xr_camera.get_parent().global_transform * adjusted_transform

	# Store adjusted transform for next frame
	prev_transform = adjusted_transform
