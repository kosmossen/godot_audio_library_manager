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
@export var ui_label_alias : Label
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
	verify_sounds()

## get data from UI elements
func get_data() -> void:
	data["settings"]["soundnames"] = ui_text_edit_sound.text
	verify_sounds()
	
## set data into UI elements
func set_data() -> void:
	if data:
		ui_label_alias.text = data["settings"]["aliasname"]
		ui_text_edit_sound.text = data["settings"]["soundnames"]
	verify_sounds()
		
## Return an array of sounds in this alias.
func get_alias_sounds() -> Array[String]:
	var _out: Array[String]
	_out.assign(data["settings"]["soundnames"].split("/"))
	return _out
		
## Verify the validity of the sounds in this alias and show warning if invalid.
func verify_sounds() -> void:
	var _sounds: Array[String] = get_alias_sounds()
	var _invalid_sounds: Array[String] = []
	if _sounds:
		for i in _sounds:
			if i not in parent_panel.data["files"]:
				_invalid_sounds.append(i)
	if _sounds == [""]:
		data["valid"] = true
		$Err.hide()
		$VBoxContainer/HBoxContainer/WarnIcon.texture = plugin.CONSTANTS.RES_NULL
		$VBoxContainer/HBoxContainer/WarnIcon.tooltip_text = "Alias is empty."
	elif _invalid_sounds:
		data["valid"] = false
		$Err.show()
		$VBoxContainer/HBoxContainer/WarnIcon.texture = plugin.CONSTANTS.RES_ERR
		$VBoxContainer/HBoxContainer/WarnIcon.tooltip_text = str("Alias contains sounds that are not found in the library: ", _invalid_sounds)
	else:
		data["valid"] = true
		$Err.hide()
		$VBoxContainer/HBoxContainer/WarnIcon.texture = plugin.CONSTANTS.RES_OK
		$VBoxContainer/HBoxContainer/WarnIcon.tooltip_text = "Alias is valid."
		
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
	parent_panel.delete_alias(id)

## Rename button pressed
func _on_button_rename_button_up() -> void:
	$RenameWindow.show()
	$RenameWindow.taken_names.clear()
	$RenameWindow.taken_names.assign(parent_panel.data["aliases"].keys())
	$VBoxContainer/HBoxContainer/ButtonRename.release_focus()

## Rename dialog accepted
func _on_rename_window_accept_pressed(entered_name: String) -> void:
	$RenameWindow.hide()
	data["settings"]["aliasname"] = entered_name
	set_data()
	emit_signal("item_updated", data)

## Add from Library button pressed
func _on_button_add_from_library_button_up() -> void:
	$ItemWindow.list_strings.assign(parent_panel.data["files"].keys())
	$ItemWindow.show()
	$ItemWindow.reload()
	$VBoxContainer/HBoxContainer/HBoxContainerTextEdit/ButtonAddFromLibrary.release_focus()

## Add from Library prompt accepted
func _on_item_window_accept_pressed(selected_items: Array[String]) -> void:
	$ItemWindow.hide()
	for i in selected_items:
		if data["settings"]["soundnames"] == "":
			data["settings"]["soundnames"] += i
		else:
			data["settings"]["soundnames"] += "/" + i
	set_data()
	emit_signal("item_updated", data)
