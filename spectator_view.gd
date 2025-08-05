extends Control

@export_group("First person view", "fpv_")
@export_range(1.0, 60.0, 1.0) var fpv_speed : float = 10.0

@onready var spectator_camera : Camera3D = $SpectatorContainer/SpectatorViewport/Camera3D
@onready var spectator_viewport : SubViewport = $SpectatorContainer/SpectatorViewport
@onready var fpv_camera : Camera3D = $FirstPersonContainer/FirstPersonViewport/Camera3D
@onready var fpv_viewport : SubViewport = $FirstPersonContainer/FirstPersonViewport
@onready var hmd_camera : XRCamera3D = $HMD/Main/CharacterBody3D/XROrigin3D/XRCamera3D

var prev_hmd_camera_transform : Transform3D

func _on_resize():
	spectator_viewport.size = get_tree().get_root().size


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_resize)
	_on_resize()

	prev_hmd_camera_transform = hmd_camera.transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Have our spectator camera look at our player.
	spectator_camera.look_at(hmd_camera.global_position)

	# We smooth out the camera 
	var hmd_camera_transform : Transform3D = hmd_camera.transform

	# Remove pitch from camera.
	hmd_camera_transform.basis = hmd_camera_transform.basis.looking_at(hmd_camera_transform.basis.z, Vector3.UP, true)

	# We (s)lerp our physical camera movement to smooth things out
	hmd_camera_transform.basis = prev_hmd_camera_transform.basis.slerp(hmd_camera_transform.basis, delta * fpv_speed)
	hmd_camera_transform.origin = prev_hmd_camera_transform.origin.lerp(hmd_camera_transform.origin, delta * fpv_speed)

	# Update our first person view.
	fpv_camera.global_transform = hmd_camera.get_parent().global_transform * hmd_camera_transform

	# Store camera transform for next frame
	prev_hmd_camera_transform = hmd_camera_transform
