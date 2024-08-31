extends Control

@onready var rotator = $CenterContainer/HBoxContainer/ColorRect/Rotator
@onready var listener = $CenterContainer/HBoxContainer/ColorRect/Listener

var time := 0.0
var rotation_speed_mul := 5
var radius := 100.0

func _physics_process(delta):
	# 2d audio rotation
	time += delta
	rotator.global_position = listener.global_position + Vector2(sin(time*rotation_speed_mul)*(radius*3), cos(time*rotation_speed_mul)*radius)

####################################################################################################

func _on_play_button_up():
	ExampleAutoload.play_2d_music(self, $CenterContainer/HBoxContainer/ColorRect/Rotator/Node2D, "music_renegade", {"panning_strength":3, "attenuation":5.0})

func _on_click_button_up():
	ExampleAutoload.play_sfx("sfx_click")
	
func _on_hurt_button_up():
	ExampleAutoload.play_sfx("sfx_hurt")

func _on_sparkle_button_up():
	ExampleAutoload.play_sfx("sfx_sparkle")

func _on_stop_1_button_up():
	ExampleAutoload.stop_sfx("sfx_sparkle")
