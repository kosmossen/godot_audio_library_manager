@tool
extends "res://addons/audio_library_manager/src/panels/panel_base.gd"
## Audio library manager library panel

signal library_updated
signal library_status_updated(status:AudioLibraryStatus)
signal library_resized

## Library item scene
const SCENE_LIBRARY_ITEM = preload("res://addons/audio_library_manager/src/panels/panel_entry.tscn")
## Alias item scene
const SCENE_ALIAS_ITEM = preload("res://addons/audio_library_manager/src/panels/panel_entry_alias.tscn")
## Minimum width below which compact UI mode is activated
const COMPACT_UI_WIDTH_THRESHOLD := 1000

@export_subgroup("Dev")
## Library status
@export var status : AudioLibraryStatus
@export var library_name_label : Node

## Status stack: if there are non-OK statuses, set _status to first one found in this array. Else if empty = status OK
var _status_stack : Array[AudioLibraryStatus]
## Is library freshly created?
var freshly_created := true
## Initialization complete
var initialized := false

################################################################################

func init(reload:bool=true) -> void:
	if Engine.is_editor_hint():
		if reload: reload(false, true)
		# no longer fresh
		freshly_created = false
		# set name
		if library_name_label: 
			library_name_label.text = id
		# global stop sounds
		parent_panel.get_node("Main/Bar/MenuBar").stop_all_sounds.connect(_on_stop_all_sounds)
		#
		initialized = true

# PRIMARY
	
## Get data from UI elements
func get_data(ignore_files:bool=false) -> void:
	#
	data["id"] = id
	if status.status_type == AudioLibraryStatus.STATUS.NEUTRAL: 
		data["fresh"] = true
	#
	data["config"]["path"] = $Pad/Stack/PlateMargin/Plate/Path/PathLineEdit.text
	var _bus_optionsbutton = $Pad/Stack/PlateMargin/Plate/Bar/BusOptionsButton
	data["config"]["bus"] = _bus_optionsbutton.get_selected_string()
	data["config"]["exclusive"] = $Pad/Stack/PlateMargin/Plate/ChecksContainer/ExclusiveCheckBox.button_pressed
	#
	if not ignore_files:
		data["files"] = {}
		data["aliases"] = {}
		var _data
		var _index := 0
		for i in panel_get_children(child_parent_control[0]):
			i.get_data()
			data["files"][i.data["metadata"]["filename"]] = i.data
			_index += 1
		for i in panel_get_children(child_parent_control[1]):
			i.get_data()
			if i.data["settings"]["aliasname"] and not i.data["settings"]["aliasname"] in data["aliases"]:
				data["aliases"][i.data["settings"]["aliasname"]] = i.data
			_index += 1

## Set data into UI elements
func set_data() -> void:
	$Pad/Stack/PlateMargin/Plate/Path/PathLineEdit.text = data["config"]["path"]
	$Pad/Stack/PlateMargin/Plate/ChecksContainer/ExclusiveCheckBox.button_pressed = data["config"]["exclusive"]
	var _index = 0
	for i in _get_audio_buses():
		if i == data["config"]["bus"]:
			$Pad/Stack/PlateMargin/Plate/Bar/BusOptionsButton.select(_index)
			_index += 1

## Play audio sample
func play_sample(stream:AudioStream, sound_name:String, poly:int=1, volume:int=0, pitch:float=0.0, bus:String="Master", title:String = "Sample") -> void:
	var asp = $AudioStreamPlayer
	if asp.get_meta("previously_played") != sound_name:
		asp.stream = stream
		asp.set_meta("previously_played", sound_name)
	asp.max_polyphony = poly
	asp.volume_db = volume
	asp.pitch_scale = pitch/100
	asp.bus = bus
	asp.play()
	$Pad/Stack/Tabs/Library/SamplePlayerPanel.play(title)
	
## Stop audio sample
func stop_sample() -> void:
	$AudioStreamPlayer.stop()
	$Pad/Stack/Tabs/Library/SamplePlayerPanel.stop()
	
## Limit files list to show files matching search parameters
func search_files(search_string:String) -> void:
	var _index = 1
	for i in panel_get_children(child_parent_control[0]):
		if search_string:
			if search_string.to_lower() in i.data["metadata"]["filename"].to_lower():
				i.visible = true
			else:
				i.visible = false
		else:
			i.visible = true
		# index
		if i.visible:
			i.index = _index
			_index += 1
			
## Limit files list to show files matching search parameters
func search_files_aliases(search_string:String) -> void:
	var _index = 1
	for i in panel_get_children(child_parent_control[1]):
		if search_string:
			if search_string.to_lower() in i.data["settings"]["aliasname"].to_lower():
				i.visible = true
			else:
				i.visible = false
		else:
			i.visible = true
		# index
		if i.visible:
			i.index = _index
			_index += 1

## Get files in directory recursively
func _get_files_recursive(path:String, file_ext_filter:Array[String]=[], files:Array=[]) -> Array:
	if verify_dir(path):
		var _dir = DirAccess.open(path)
		if _dir.open(path):
			_dir.list_dir_begin()
			var file_name = _dir.get_next()
			while file_name != "":
				if _dir.current_is_dir():
					files = _get_files_recursive(_dir.get_current_dir().path_join(file_name), file_ext_filter, files)
				else:
					if file_ext_filter and not file_name.get_extension() in file_ext_filter:
						file_name = _dir.get_next()
						continue
					files.append([file_name.replace(".%s"%(file_name.get_extension()), ""), file_name.get_extension(), _dir.get_current_dir().path_join(file_name)])
				file_name = _dir.get_next()
			_dir.list_dir_end()
		else:
			return []
		return files
	return []

## get files from configured directory and recreate entries
func reload_files(use_existing_data:bool=false) -> void:
	get_data(use_existing_data)
	# clear files
	panel_delete_children(child_parent_control[0])
	panel_delete_children(child_parent_control[1])
	if subpanels: 
		subpanels = {}
	if data:
		if data["config"]["path"]:
			if verify_dir(data["config"]["path"]):
				## get all sound files from directory into an array
				var _files = []
				_files = _get_files_recursive(data["config"]["path"], plugin.CONSTANTS.VALID_FORMATS)
				# no files?
				if not _files:
					_status_stack_append("No suitable audio files found in directory.", AudioLibraryStatus.STATUS.WARN)
				# new files
				var _index = 1
				for i in _files:
					var _item
					if use_existing_data:
						if i[0] in data["files"]:
							_item = panel_create_child(child_parent_control[0], SCENE_LIBRARY_ITEM, i[0]+i[1], data["files"][i[0]], false, false)
							var _init_settings = {}
							for j in data["files"][i[0]]["settings"]: 
								if j in plugin.CONSTANTS.TEMPLATE_ENTRY["settings"]:
									_init_settings[j] = data["files"][i[0]]["settings"][j]
							_item.init_data(i[0], i[1], i[2], _init_settings)
						else:
							_item = panel_create_child(child_parent_control[0], SCENE_LIBRARY_ITEM, i[0]+i[1], plugin.CONSTANTS.TEMPLATE_ENTRY)
							_item.init_data(i[0], i[1], i[2])
					else:
						_item = panel_create_child(child_parent_control[0], SCENE_LIBRARY_ITEM, i[0]+i[1], plugin.CONSTANTS.TEMPLATE_ENTRY)
						_item.init_data(i[0], i[1], i[2])
					_item.get_data()
					_item.index = _index
					_item.item_updated.connect(_item_updated)
					_index += 1
				# new aliases
				_index = 1
				if "aliases" not in data:
					data["aliases"] = {}
				for i in data["aliases"]:
					var _alias
					_alias = panel_create_child(child_parent_control[1], SCENE_ALIAS_ITEM, i, plugin.CONSTANTS.TEMPLATE_ALIAS_ENTRY)
					_alias.init_data(data["aliases"][i]["settings"]["aliasname"], data["aliases"][i]["settings"]["soundnames"])
					_alias.get_data()
					_alias.index = _index
					_alias.item_updated.connect(_item_updated)
					_index += 1
				
## Reload library
func reload(use_existing_data:bool=false, initial:bool=false) -> void:
	# Prevent reloading with existing data if not initialized
	if not initialized and use_existing_data:
		return
	###
	_status_stack_clear()
	###
	# dont use existing data if there is no existing data
	if not data["files"]: use_existing_data = false
	# verify library path
	var _library_path = $Pad/Stack/PlateMargin/Plate/Path/PathLineEdit
	if _library_path.text:
		if not verify_dir(_library_path.text):
			_status_stack_append("Directory not found at given source path '%s'!" % _library_path.text, AudioLibraryStatus.STATUS.CRIT)
	else:
		_status_stack_append("No source path given!", AudioLibraryStatus.STATUS.CRIT)
	# verify existence of bus
	var _bus_optionsbutton = $Pad/Stack/PlateMargin/Plate/Bar/BusOptionsButton
	var _bus_optionsbutton_selected = _bus_optionsbutton.get_item_text(_bus_optionsbutton.get_selected_id())
	if not _bus_optionsbutton_selected in _get_audio_buses():
		_status_stack_append("Audio bus '%s' not found in project!" % _bus_optionsbutton_selected, AudioLibraryStatus.STATUS.CRIT)
	###
	# get and refresh bus selection button
	var _bus = ""
	if initial:
		if data["config"]["bus"]:
			_bus = data["config"]["bus"]
	_bus_optionsbutton.set_options(_get_audio_buses(), true, _bus)
	###
	# get library files
	reload_files(use_existing_data)
	get_data(use_existing_data)
	###
	if freshly_created:
		_status_stack_clear()
		_status_stack_append("Uninitialized", AudioLibraryStatus.STATUS.NEUTRAL)
	_refresh_status_from_stack()
	# set status label text and color according to status
	var _status_label = $Pad/Stack/PlateMargin/Plate/Status/StatusLabel
	_status_label.label_settings.set_font_color(status.STATUS_COLOR[status.status_type])
	_status_label.text = status.status_msg
	# reapply search
	var _searchtext = $Pad/Stack/Tabs/Library/Search.text
	if _searchtext: search_files(_searchtext)
	var _searchtext_aliases = $Pad/Stack/Tabs/Aliases/SearchAliases.text
	if _searchtext_aliases: search_files_aliases(_searchtext)
	# signal
	emit_signal("library_updated")

func delete_alias(id:String) -> void:
	panel_delete_child(child_parent_control[1], id)
	data["aliases"].erase(id)
	reload(true)

# STATUS

## Add to status stack
func _status_stack_append(msg:String, type:AudioLibraryStatus.STATUS) -> void:
	var _new = AudioLibraryStatus.new()
	_new.status_msg = msg
	_new.status_type = type
	_status_stack.append(_new)
	_refresh_status_from_stack()

## Clear status stack
func _status_stack_clear() -> void:
	_status_stack = []
	_refresh_status_from_stack()

## Refresh main status based on status stack
func _refresh_status_from_stack() -> void:
	if not _status_stack:
		status = AudioLibraryStatus.new()
	for i in _status_stack:
		if i.status_type != i.STATUS.OK:
			status = i
	emit_signal("library_status_updated", status)

# AUXILIARY

## Get names of audio buses from project
func _get_audio_buses() -> Array[String]:
	var _out : Array[String]
	for i in AudioServer.bus_count:
		_out.append(AudioServer.get_bus_name(i))
	return _out

# VERIFICATION

## Verify: directory
func verify_dir(path:String) -> bool:
	if not path or path == "res://" or path.begins_with("user://"): 
		return false
	return DirAccess.dir_exists_absolute(path)

# SIGNALS

## Item updated
func _item_updated(data:Dictionary) -> void:
	get_data()
	emit_signal("library_updated")
	reload(true)

## Rename library
func _on_rename_button_up() -> void:
	$RenameWindow.taken_names = parent_panel.panel_get_ids(parent_panel.child_parent_control[0], true)
	$RenameWindow.show()
	$Pad/Stack/PlateMargin/Plate/Titlebar/Rename.release_focus()

## Rename accepted
func _on_rename_window_accept_pressed(entered_name) -> void:
	var _old = id
	set_id(entered_name)
	parent_panel.rename_library(_old, entered_name)
	get_data()
	if library_name_label: 
		library_name_label.text = entered_name
	emit_signal("library_updated")

## Delete library
func _on_delete_button_up() -> void:
	$DeleteDialog.dialog_text = "Are you sure you want to delete library '%s'?\nThe library configuration will be lost!" % id
	$DeleteDialog.show()
	$Pad/Stack/PlateMargin/Plate/Titlebar/Delete.release_focus()
	
## Delete dialog accepted
func _on_delete_dialog_confirmed():
	parent_panel.delete_library(id)

## Reload library via reload button
func _on_reload_button_up() -> void:
	if initialized:
		reload(true)

## Search (Entries)
func _on_line_edit_text_changed(new_text) -> void:
	search_files(new_text)
	
## Search (Aliases)
func _on_search_aliases_text_changed(new_text) -> void:
	search_files_aliases(new_text)

## Stop audio sample
func _on_sample_player_button_stop_button_up():
	stop_sample()
	
## Audio sample done playing
func _on_audio_stream_player_finished():
	$Pad/Stack/Tabs/Library/SamplePlayerPanel.stop()

## FileDialog dir selected
func _on_file_dialog_dir_selected(dir):
	$Pad/Stack/PlateMargin/Plate/Path/PathLineEdit.text = dir
	$FileDialog.hide()
	if initialized:
		reload(true)

## FileDialog open
func _on_file_dialog_button_button_up():
	$FileDialog.show()

## FileDialog close
func _on_file_dialog_close_requested():
	$FileDialog.hide()

## Global stop all sounds
func _on_stop_all_sounds():
	stop_sample()

## New path set
func _on_path_line_edit_text_changed(new_text):
	if initialized:
		reload(true)

## Audio bus selected
func _on_bus_options_button_item_selected(index):
	if initialized:
		reload(true)

## Exclusive mode toggled
func _on_exclusive_check_box_toggled(toggled_on):
	if initialized:
		reload(true)

## Library resized
func _on_resized():
	emit_signal("library_resized")
	if size.x < COMPACT_UI_WIDTH_THRESHOLD:
		ui_mode = UI_MODE.COMPACT
	else:
		ui_mode = UI_MODE.NORMAL

## New alias (prompt)
func _on_button_new_alias_button_up() -> void:
	$NewAliasWindow.taken_names.clear()
	$NewAliasWindow.taken_names.assign(data["aliases"].keys())
	$NewAliasWindow.show()
	$Pad/Stack/Tabs/Aliases/HBoxContainer/ButtonNewAlias.release_focus()

## Clear all aliases (prompt)
func _on_button_clear_aliases_button_up() -> void:
	$ClearAliasesDialog.show()
	$Pad/Stack/Tabs/Aliases/HBoxContainer/ButtonClearAliases.release_focus()

## Reload when children are updated to ensure that removals are saved
func _on_children_updated() -> void:
	reload(true)

## Create new alias (prompt accepted)
func _on_new_alias_window_accept_pressed(entered_name: String) -> void:
	$NewAliasWindow.hide()
	var _new_alias_string: String = entered_name
	data["aliases"][_new_alias_string] = plugin.CONSTANTS.TEMPLATE_ALIAS_ENTRY.duplicate(true)
	data["aliases"][_new_alias_string]["settings"]["aliasname"] = _new_alias_string
	reload(true)

## Clear aliases (prompt accepted)
func _on_clear_aliases_dialog_confirmed() -> void:
	$ClearAliasesDialog.hide()
	data["aliases"].clear()
	reload(true)
