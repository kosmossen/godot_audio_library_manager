@tool
extends "res://addons/audio_library_manager/src/panels/panel_base.gd"
## Audio library manager primary panel

signal library_list_updated
	
## Plugin data location and filename
const PATH_DATA = "res://addons/audio_library_manager/data/"
const PATH_DATA_FILE = "data.json"
## preload
const SCENE_LIBRARY := preload("res://addons/audio_library_manager/src/panels/panel_library.tscn")

################################################################################

# GODOT

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		# update version text
		$Main/Bar/Version.text = "%s" % _get_plugin_version()
		# pre-cleaning
		panel_delete_children(child_parent_control[0])
		$Main/Menu/VBoxContainer/ItemList.clear()
		# load config
		if load_data():
			if subpanels:
				recreate_libraries_from_data()

# PRIMARY
	
func delete_library(id:String) -> void:
	panel_delete_child(child_parent_control[0], id)
	emit_signal("library_list_updated")
	save_data()
	$Main/Menu/VBoxContainer/ItemList.select_null()
	
func delete_all_libraries() -> void:
	panel_delete_children(child_parent_control[0])
	emit_signal("library_list_updated")
	save_data()
	$Main/Menu/VBoxContainer/ItemList.select_null()
	
func new_library(id:String="Library", select_new:bool=false) -> void:
	# make sure id is unique
	var _ids = panel_get_ids(child_parent_control[0])
	if id in _ids:
		var _temp = id + ("_")
		while _ids.has(_temp):
			_temp = _temp + ("_")
		id = _temp
	#
	var _child = panel_create_child(child_parent_control[0], SCENE_LIBRARY, id, plugin.CONSTANTS.TEMPLATE_LIBRARY)
	_child.library_updated.connect(_on_library_updated)
	_child.library_status_updated.connect(_on_library_status_updated)
	_child.init()
	emit_signal("library_list_updated")
	# select new if so desired
	if select_new: $Main/Menu/VBoxContainer/ItemList.select_last_id()
	
## Safely rename a library
func rename_library(old_id:String, new_id:String) -> void:
	if old_id in panel_get_ids(child_parent_control[0]):
		subpanels[child_parent_control[0]][new_id] = subpanels[child_parent_control[0]][old_id].duplicate(true)
		subpanels[child_parent_control[0]].erase(old_id)
	
## Use data to create libraries
func recreate_libraries_from_data() -> void:
	for i in subpanels[child_parent_control[0]]:
		var _new = panel_create_child(child_parent_control[0], SCENE_LIBRARY, i, subpanels[child_parent_control[0]][i], false, false)
		_new.library_updated.connect(_on_library_updated)
		_new.library_status_updated.connect(_on_library_status_updated)
		_new.set_data()
		_new.init(false)
		_new.reload(true, true)
		emit_signal("library_list_updated")

# FILE HANDLING
 
## Save data to config.json
func save_data(full_overwrite:bool=true) -> void:
	var _dict = {}
	if subpanels[child_parent_control[0]]: _dict = subpanels[child_parent_control[0]]
	AudioLibraryData.data_save(_dict, full_overwrite)
	
## Load data from config.json
func load_data() -> bool:
	var _subpanels = AudioLibraryData.data_load()
	if not _subpanels:
		return false
	subpanels[child_parent_control[0]] = _subpanels
	return true
	
## Import file
func import() -> void:
	$ImportDialog.show()
	
## Export file
func export() -> void:
	$ExportDialog.show()
	
# SIGNALS

## New library
func _on_button_button_up() -> void:
	new_library("Library", true)
	
## Library status updated
func _on_library_status_updated(status:AudioLibraryStatus) -> void:
	emit_signal("library_list_updated")
	save_data()
	
## Library updated
func _on_library_updated() -> void:
	emit_signal("library_list_updated")
	save_data()

## Import dialog accepted
func _on_import_ok(path):
	var _err = AudioLibraryData.data_import(path)
	if _err != OK:
		var _dialog = $ImportFailDialog
		match _err:
			ERR_DOES_NOT_EXIST:
				_dialog.get_label().text = "Data import failed. File does not exist."
			ERR_INVALID_DATA:
				_dialog.get_label().text = "Data import failed. Import data is invalid or corrupt."
		_dialog.show()
	else:
		panel_delete_children(child_parent_control[0])
		$Main/Menu/VBoxContainer/ItemList.clear()
		if load_data():
			if subpanels:
				recreate_libraries_from_data()
				$ImportSuccessDialog.show()

## Export dialog accepted
func _on_export_ok(path):
	var _err = AudioLibraryData.data_export(path)
	if _err != OK:
		var _dialog = $ExportFailDialog
		match _err:
			ERR_INVALID_PARAMETER:
				_dialog.get_label().text = "Data export failed. Exported file must be a JSON file."
			ERR_ALREADY_EXISTS:
				_dialog.get_label().text = "Data import failed. File already exists and overwriting is disabled."
		_dialog.show()
	else:
		$ExportSuccessDialog.show()

## Dialog: clear all
func _on_clear_confirm_dialog_confirmed():
	delete_all_libraries()
