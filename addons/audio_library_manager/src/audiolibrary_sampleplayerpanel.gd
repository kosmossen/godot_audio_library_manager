@tool
extends HBoxContainer
## Audio library manager: sample player panel handler

const color_playing : Color = Color.WHITE
const color_stopped : Color = Color.DARK_SLATE_GRAY
const string_stopped : String = "NOT PLAYING"

# GODOT

func _enter_tree():
	stop()

# PRIMARY 

func play(sample_title:String) -> void:
	$SamplePlayerLabelCurrent.label_settings.set_font_color(color_playing)
	$SamplePlayerLabelCurrent.text = "PLAYING: %s" % sample_title
	$SamplePlayerButtonStop.disabled = false
	
func stop() -> void:
	$SamplePlayerLabelCurrent.label_settings.set_font_color(color_stopped)
	$SamplePlayerLabelCurrent.text = string_stopped
	$SamplePlayerButtonStop.disabled = true
