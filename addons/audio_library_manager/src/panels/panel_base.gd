extends Control
## Audio library manager base panel

signal id_set(parent:Control, old_id:String, new_id:String)
signal ui_mode_changed(new_mode:UI_MODE)
signal children_updated()
signal delete_requested(parent:Node, id:String)

enum UI_MODE {
	NORMAL,
	COMPACT
}

## Plugin cfg
const PATH_PLUGIN_CFG = "res://addons/audio_library_manager/plugin.cfg"

## Panel identifier
@export var id := "panel"
## Panel data
@export var data := {}
## Target parent node for instantiating children
@export var child_parent_control : Array[Control]

## Plugin reference
var plugin
## Am I the root panel?
var root := true
## Child panels
var subpanels := {}
## Root panel
var root_panel : Control
## Parent panels
var parent_panel : Control
## Child data dictionary tag
var child_data_dict_tag : String = "panels"
## Compact UI mode
var ui_mode : UI_MODE = UI_MODE.NORMAL:
	set(v):
		ui_mode = v
		emit_signal("ui_mode_changed", v)

################################################################################

# GODOT

func _init():
	plugin = Engine.get_meta("AudioLibraryManagerPlugin")

# PLUGIN

## Return plugin version string
func _get_plugin_version() -> String:
	var _cfg = ConfigFile.new()
	var _err = _cfg.load(PATH_PLUGIN_CFG)
	if _err != OK:
		return "(plugin.cfg not found)"
	else:
		return _cfg.get_value("plugin", "version", "0.0")

# PRIMARY

## Set the ID of this panel (aka rename the panel)
func set_id(new_id:String) -> void:
	if new_id:
		var _old = id
		id = new_id
		emit_signal("id_set", _old, new_id)

## Create a child panel under the child parent control node #
func panel_create_child(parent_control:Control, child_node:PackedScene, id:String, initial_data:Dictionary, duplicate_initial_data:bool = true, get_data_ref_from_child:bool = true) -> Variant:
	if child_node and parent_control and id:
		var _child = child_node.instantiate()
		_child.id = id
		if _child.is_in_group("AudioLibraryPanel"):
			_child.root = false
			parent_control.add_child(_child)
			_child.parent_panel = self
			if root:
				_child.root_panel = self
			else:
				_child.root_panel = root_panel
			if initial_data: 
				if duplicate_initial_data: 
					_child.data = initial_data.duplicate(true)
				else:
					_child.data = initial_data
			if not parent_control in subpanels:
				subpanels[parent_control] = {}
			if "data" in _child and get_data_ref_from_child:
				subpanels[parent_control][id] = _child.data
			_child.id_set.connect(_on_child_id_set)
			_child.delete_requested.connect(_on_child_delete_requested)
			ui_mode_changed.connect(_child._on_parent_ui_mode_changed)
			#emit_signal("children_updated")
			return _child
		else:
			push_error("Unable to create child panel: child is not in group 'AudioLibraryPanel'")
			_child.queue_free()
			return false
	push_error("Unable to create child panel: no child node, parent control node or ID provided.")
	return false

## Delete a child panel by ID
func panel_delete_child(parent_control:Control, id:String) -> bool:
	if child_parent_control:
		var _child = panel_get_child(parent_control, id)
		if _child:
			if _child.is_in_group("AudioLibraryPanel") and _child.id == id:
				# not optimal but there was some issues with the entry for the deleted libraries sticking around in itemlists
				_child.hide()
				_child.get_parent().remove_child(_child)
				add_child(_child)
				_child.queue_free()
				if subpanels[parent_control].has(id):
					subpanels[parent_control].erase(id)
				#emit_signal("children_updated")
				return true
	return false
	
## Delete all children
func panel_delete_children(parent_control:Control) -> void:
	for i in panel_get_ids(parent_control):
		panel_delete_child(parent_control, i)
	subpanels[parent_control] = {}
					
## Get an existing panel by ID #
func panel_get_child(parent_control:Control, id:String) -> Variant:
	for i in parent_control.get_children():
		if i.is_in_group("AudioLibraryPanel"):
			if i.id == id: return i
	return false
	
## Get all panels #
func panel_get_children(parent_control:Control=null) -> Array[Control]:
	var _out : Array[Control] = []
	for i in parent_control.get_children():
		if i.is_in_group("AudioLibraryPanel"):
			_out.append(i)
	return _out
	
## Get all panel IDs
func panel_get_ids(parent_control:Control, lowercase:bool=false) -> Array[String]:
	var _libraries = panel_get_children(parent_control)
	var _out : Array[String] = []
	for i in _libraries:
		if i.is_in_group("AudioLibraryPanel"):
			if lowercase:
				_out.append(i.id.to_lower())
			else:
				_out.append(i.id)
	return _out

## Append data onto this panel
func panel_append_data(data_tag:String, data, overwrite:bool=false) -> void:
	if not data["data"].has(data_tag):
			data["data"][data_tag] = data
	elif overwrite:
		data["data"][data_tag] = data

## Set panel data
func panel_set_data(new_data:Dictionary, duplicate:bool=false) -> void:
	if duplicate:
		data["data"] = new_data.duplicate(true)
	else:
		data["data"] = new_data
	emit_signal("data_updated", data)
	
# SIGNALS

## Update a child's id in this panel's data when a child renames itself
func _on_child_id_set(parent:Control, old_id:String, new_id:String) -> void:
	if old_id in subpanels[parent]:
		subpanels[parent][new_id] = subpanels[parent][old_id]
		subpanels[parent].erase(old_id)

## Child requested deletion
func _on_child_delete_requested(parent:Control, id:String) -> void:
	panel_delete_child(parent, id)

func _on_parent_ui_mode_changed(new_mode:UI_MODE) -> void:
	ui_mode = new_mode
