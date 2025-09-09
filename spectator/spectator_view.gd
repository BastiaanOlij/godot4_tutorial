extends Control

@onready var stabilized_camera : Camera3D = $Frame/FirstPersonContainer/FirstPersonViewport/StabilizedCamera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$FOVSlider.value = stabilized_camera.fov


func _on_fov_slider_value_changed(value):
	stabilized_camera.fov = value
