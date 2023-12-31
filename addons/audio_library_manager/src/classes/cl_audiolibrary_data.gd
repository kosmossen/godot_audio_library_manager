@tool
class_name AudioLibraryData extends Resource
## Audio Library Manager Data Manager
## The AudioLibraryData class is used to save, load and verify audio library data files.

## Plugin data path and filename
const PATH_DATA = "res://addons/audio_library_manager/data/"
const PATH_DATA_FILE = "data.json"
## Data source plugin verification string. changing this will break compatibility.
const PLUGIN_STRING = "godot_audio_library_manager"

var plugin

################################################################################

# VERIFICATION

## Verify data
static func data_verify(data:Dictionary) -> bool:
	if not "plugin" in data:
		return false
	if not "data" in data:
		return false
	if not data["plugin"] == PLUGIN_STRING:
		return false
	return true

# FILE HANDLING

## Save data to data file. Full overwrite overwrites the entire data file when saving rather than only existing data keys being overwritten by new data.
static func data_save(data:Dictionary, full_overwrite:bool=true, bypass_verification:bool=false) -> Error:
	var _old_data
	var _final_data
	if not full_overwrite:
		_old_data = data_load()
	if _old_data:
		_old_data.merge(data)
		_final_data = _old_data
	else:
		_final_data = data
	var _dict = {
		"plugin" : PLUGIN_STRING,
		"data" : _final_data
	}
	if not data_verify(_dict) and not bypass_verification:
		push_error("Verification of data to-be-saved failed, data may be invalid or corrupted.")
		return ERR_INVALID_DATA
	if not DirAccess.dir_exists_absolute(PATH_DATA): 
		DirAccess.make_dir_absolute(PATH_DATA)
	var _file = FileAccess.open(PATH_DATA+PATH_DATA_FILE, FileAccess.WRITE)
	_file.store_line(JSON.stringify(_dict, "\t"))
	_file.close()
	return OK
	
## Load data from data file
static func data_load(include_frame:bool=false, bypass_verification:bool=false, create_new_on_missing:bool=true) -> Variant:
	# fileaccess
	var _out
	if FileAccess.file_exists(PATH_DATA+PATH_DATA_FILE):
		var _file = FileAccess.open(PATH_DATA+PATH_DATA_FILE, FileAccess.READ)
		_out = JSON.parse_string(_file.get_as_text())
	elif not create_new_on_missing:
		push_error("Verification of loaded file failed, file not found.")
		return ERR_DOES_NOT_EXIST
	else:
		data_save({})
		var _file = FileAccess.open(PATH_DATA+PATH_DATA_FILE, FileAccess.READ)
		_out = JSON.parse_string(_file.get_as_text())
	if not data_verify(_out) and not bypass_verification:
		push_error("Verification of loaded file failed, data may be invalid or corrupted.")
		return ERR_FILE_CORRUPT
	if include_frame:
		return _out
	return _out["data"]

## Import data
static func data_import(path:String) -> Error:
	# fileaccess
	var _out
	if FileAccess.file_exists(path):
		var _file = FileAccess.open(path, FileAccess.READ)
		_out = JSON.parse_string(_file.get_as_text())
	else:
		push_error("Data import failed, file does not exist.")
		return ERR_DOES_NOT_EXIST
	if not data_verify(_out):
		push_error("Data import failed, data may be invalid or corrupted.")
		return ERR_INVALID_DATA
	data_save(_out["data"])
	return OK

## Export data
static func data_export(path:String, allow_overwrite:bool=true) -> Error:
	var _data = data_load(true)
	if path.get_extension() == "":
		path += ".json"
	if not path.get_extension() == "json":
		push_error("Data export failed, export file must be a JSON file.")
		return ERR_INVALID_PARAMETER
	if FileAccess.file_exists(path) and not allow_overwrite:
		push_error("Data export failed, file already exists at export path.")
		return ERR_ALREADY_EXISTS
	var _file = FileAccess.open(path, FileAccess.WRITE)
	_file.store_line(JSON.stringify(_data, "\t"))
	_file.close()
	return OK
