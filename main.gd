extends Node3D

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		var vp : Viewport = get_viewport()

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		vp.use_xr = true

		# Enable VRS (foveated rendering).
		# Vulkan only, for Compatibility see project settings.
		vp.vrs_mode = Viewport.VRS_XR

		print("OpenXR initialised successfully")
	else:
		print("OpenXR not initialized, please check if your headset is connected")
