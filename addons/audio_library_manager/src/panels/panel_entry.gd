@tool
extends "res://addons/audio_library_manager/src/panels/panel_base.gd"
## Audio library manager library entry

signal item_updated(data:Dictionary)

## Maximum alpha of volume warning background
const VOLUME_BG_MAX_ALPHA := 0.25

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
@export var ui_settingscontainer : Control
@export var ui_settingsbutton : Control
@export var ui_volume : Control
@export var ui_pitch : Control
@export var ui_poly : Control
@export var ui_volume_bg : Control
@export var ui_filename : Control
@export var ui_filetype : Control
@export var ui_filesubpath : Control
@export var ui_resetbutton : Control

var _pause_setting_updates := false

################################################################################

# PRIMARY

### initialize with data
func init_data(filename:String, filetype:String, filepath:String, settings_init:Dictionary={}, set_data:bool=true) -> void:
	data["metadata"]["filename"] = filename
	data["metadata"]["filetype"] = filetype
	data["metadata"]["path"] = filepath
	for i in plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS:
		if i in settings_init:
			data["settings"][i] = settings_init[i]
	if set_data: 
		set_data()

## get data from UI elements
func get_data() -> void:
	data["settings"]["volume"] = clamp(ui_volume.value/plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["scale"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["min"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["max"])
	data["settings"]["pitch"] = clamp(ui_pitch.value/plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["scale"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["min"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["max"])
	data["settings"]["poly"] = clamp(ui_poly.value/plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["poly"]["scale"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["poly"]["min"], plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["poly"]["max"])
	# volume warning background color
	ui_volume_bg.color.a = (clamp(data["settings"]["volume"], 0, plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["max"]) / plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["max"]) * VOLUME_BG_MAX_ALPHA
	refresh_reset_button()
	
## set data into UI elements
func set_data() -> void:
	if data:
		ui_filename.text = data["metadata"]["filename"]
		ui_filetype.text = ".%s" % data["metadata"]["filetype"]
		ui_volume.value = data["settings"]["volume"]*plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["scale"]
		ui_pitch.value = data["settings"]["pitch"]*plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["scale"]
		ui_poly.value = data["settings"]["poly"]*plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["poly"]["scale"]
		var _subpath = data["metadata"]["path"].replace(parent_panel.data["config"]["path"].simplify_path(), "").replace("%s.%s" % [data["metadata"]["filename"], data["metadata"]["filetype"]], "")
		if _subpath == "/":
			_subpath = ""
		ui_filesubpath.text = _subpath
		# volume warning background color
		ui_volume_bg.color.a = (clamp(data["settings"]["volume"], 0, plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["max"]) / plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["max"]) * VOLUME_BG_MAX_ALPHA
		refresh_reset_button()
		
func reset_to_default() -> void:
	_pause_setting_updates = true
	data["settings"]["volume"] = plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["default"]
	data["settings"]["pitch"] = plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["default"]
	data["settings"]["poly"] = plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["poly"]["default"]
	set_data()
	_pause_setting_updates = false
		
## Refresh status of reset button
func refresh_reset_button() -> void:
	var _default = true
	for i in plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS:
		if i in data["settings"]:
			if not data["settings"][i] == plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS[i]["default"]:
				_default = false
	if _default == false:
		ui_resetbutton.modulate.a = 1.0
		ui_resetbutton.tooltip_text = "Reset to Default"
		ui_resetbutton.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		ui_resetbutton.modulate.a = 0.0
		ui_resetbutton.tooltip_text = ""
		ui_resetbutton.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
func check_template_key(key:String) -> bool:
	if plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS[key]["control_var"] in self:
		if key in data["settings"]:
			return true
	return false
		
# SIGNALS

## Highlight active on mouse enter
func _on_h_box_container_mouse_entered() -> void:
	$Highlight.visible = true

## Highlight inactive on mouse exit
func _on_h_box_container_mouse_exited() -> void:
	$Highlight.visible = false

## Settings changed, get data and send signal
func _on_setting_changed(value):
	if not _pause_setting_updates:
		get_data()
		emit_signal("item_updated", data)

## Play audio sample
func _on_play_button_up():
	var _stream = load(data["metadata"]["path"])
	parent_panel.play_sample(
		_stream,
		data["settings"]["volume"]*plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["volume"]["scale"], 
		data["settings"]["pitch"]*plugin.CONSTANTS.TEMPLATE_SOUND_SETTINGS["pitch"]["scale"], 
		parent_panel.data["config"]["bus"],
		"%s.%s" % [data["metadata"]["filename"], data["metadata"]["filetype"]]
	)

## Show sound file info
func _on_info_button_up():
	var _window = parent_panel.get_node("InfoWindow")
	_window.filename = "%s.%s" % [data["metadata"]["filename"], data["metadata"]["filetype"]]
	_window.filepath = data["metadata"]["path"]
	_window.show()

## UI mode
func _on_parent_ui_mode_changed(new_mode:UI_MODE):
	super(new_mode)
	match ui_mode:
		UI_MODE.NORMAL:
			ui_settingscontainer.show()
			ui_settingsbutton.hide()
		UI_MODE.COMPACT:
			ui_settingscontainer.hide()
			ui_settingsbutton.show()

## Reset to default
func _on_reset_button_button_down():
	reset_to_default()
	emit_signal("item_updated", data)

## Show settings in borrow window
func _on_settings_button_button_up():
	var _borrow_window = $SettingBorrowWindow
	_borrow_window.borrow(ui_settingscontainer, "Settings for %s.%s" % [data["metadata"]["filename"], data["metadata"]["filetype"]])
	_borrow_window.show()
