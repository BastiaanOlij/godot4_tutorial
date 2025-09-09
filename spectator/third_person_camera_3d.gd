extends Camera3D

@export var look_at_node : Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not look_at_node:
		return

	# Have our spectator camera look at our player.
	look_at(look_at_node.global_position)
