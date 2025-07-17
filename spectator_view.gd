extends Control


@onready var spectator_camera : Camera3D = $SpectatorContainer/SpectatorViewport/Camera3D
@onready var spectator_viewport : SubViewport = $SpectatorContainer/SpectatorViewport
@onready var hmd_camera : XRCamera3D = $HMD/Main/CharacterBody3D/XROrigin3D/XRCamera3D

func _on_resize():
	spectator_viewport.size = get_tree().get_root().size


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_resize)
	_on_resize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spectator_camera.look_at(hmd_camera.global_position)
