@tool
extends "res://addons/audio_library_manager/src/panels/panel_base.gd"
## Audio library manager alias entry

signal item_updated(data:Dictionary)

## Entry index in list
@export var index : int = 0:
	set(v):
		index = v
		# darken on odd index
		if index % 2 == 1: 
			$Darken.visible = true 
		else: 
			$Darken.visible = false
# ui items/control references
@export_subgroup("Control References")
@export var ui_text_edit_alias : LineEdit
@export var ui_text_edit_sound : LineEdit
@export var ui_warn_icon : TextureRect

################################################################################

# PRIMARY

## initialize with data
func init_data(alias_name:String, sound_names:String, set_data:bool=true) -> void:
	data["settings"]["aliasname"] = alias_name
	data["settings"]["soundnames"] = sound_names
	if set_data: 
		set_data()

## get data from UI elements
func get_data() -> void:
	data["settings"]["aliasname"] = ui_text_edit_alias.text
	data["settings"]["soundnames"] = ui_text_edit_sound.text
	
## set data into UI elements
func set_data() -> void:
	if data:
		ui_text_edit_alias.text = data["settings"]["aliasname"]
		ui_text_edit_sound.text = data["settings"]["soundnames"]
		
# SIGNALS

## Highlight active on mouse enter
func _on_h_box_container_mouse_entered() -> void:
	$Highlight.visible = true

## Highlight inactive on mouse exit
func _on_h_box_container_mouse_exited() -> void:
	$Highlight.visible = false
	
## Settings changed, get data and send signal
func _on_setting_changed(value):
	get_data()
	emit_signal("item_updated", data)

## Delete entry
func _on_button_delete_button_up() -> void:
	emit_signal("delete_requested", parent_panel, id)
