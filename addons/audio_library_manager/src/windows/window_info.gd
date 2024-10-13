@tool
extends "res://addons/audio_library_manager/src/windows/window_base.gd"
## Audio Library Manager: sound info window

var filename : String = "file.ogg":
	set(v):
		filename = v
		$Panel/CenterContainer/Container/NameLabelContainer/CenterContainer/NameLabel.text = v
var filepath : String = "res://path/file.ogg":
	set(v):
		filepath = v
		$Panel/CenterContainer/Container/PathLabelContainer/CenterContainer/PathLabel.text = v

## Close window
func _on_ok_button_up():
	hide()
