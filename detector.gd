extends Area3D

signal toggled(is_on)

@export var on : bool = false:
	set(value):
		on = value
		if is_inside_tree():
			_update_on()

@export var on_color : Color = Color(1.0, 0.0, 0.0)
@export var off_color : Color = Color(0.5, 0.0, 0.0)

var can_toggle = true

func _update_on():
	var material : StandardMaterial3D = $MeshInstance3D.material_override
	if material:
		material.albedo_color = on_color if on else off_color

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_on()


func _on_body_entered(body):
	if can_toggle:
		on = not on
		toggled.emit(on)
		can_toggle = false
		$Timer.start()


func _on_timer_timeout():
	can_toggle = true
