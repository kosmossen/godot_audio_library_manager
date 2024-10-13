extends Node3D

@onready var rotator = $Rotator
@onready var listener = $Listener

var time := 0.0
var rotation_speed_mul := 3
var radius := 1.0

func _physics_process(delta):
	# 3d audio rotation
	time += delta
	rotator.global_position = listener.global_position + Vector3(
		sin(time*rotation_speed_mul)*(radius*3), 
		cos(time*rotation_speed_mul)*radius, 
		sin(time*rotation_speed_mul/2)*(radius*3)
		)
	rotator.rotate_x(PI/64)
	rotator.rotate_z(PI/128)

####################################################################################################

func _on_button_button_up():
	ExampleAutoload.play_3d_music(self, rotator, "music_renegade", {"panning_strength":0.5, "attenuation":10.0})
