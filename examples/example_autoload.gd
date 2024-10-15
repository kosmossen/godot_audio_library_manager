extends Node

@onready var audiolibrary = AudioLibrary.initialize(self)

func play_sfx(sfx:String) -> void:
	audiolibrary.play_sound("SFX", sfx)
	
func stop_sfx(sfx:String) -> void:
	audiolibrary.stop_sound("SFX", sfx)
	
func play_2d_music(world:Node, parent:Node2D, sfx:String, properties:Dictionary) -> void:
	audiolibrary.play_2d_sound(world, parent, "Music", sfx, properties)
	
func play_3d_music(world:Node, parent:Node3D, sfx:String, properties:Dictionary) -> void:
	audiolibrary.play_3d_sound(world, parent, "Music", sfx, properties)
