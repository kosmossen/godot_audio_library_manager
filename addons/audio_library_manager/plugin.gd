@tool
extends EditorPlugin
## Godot Audio Library Manager

const CONSTANTS = preload("./src/audiolibrary_constants.gd")
#
const PANEL_MAIN = preload("res://addons/audio_library_manager/src/panels/panel_primary.tscn")
const ICON = preload("res://addons/audio_library_manager/res/icon.svg")

var panel_main_instance

################################################################################

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		# add meta reference
		Engine.set_meta("AudioLibraryManagerPlugin", self)
		# instantiate main panel
		panel_main_instance = PANEL_MAIN.instantiate()
		# add main panel to editor viewport
		get_editor_interface().get_editor_main_screen().add_child(panel_main_instance)
		# hide main panel
		_make_visible(false)

func _exit_tree() -> void:
	if panel_main_instance:
		# remove meta references
		Engine.remove_meta("AudioLibraryManagerPlugin")
		#
		panel_main_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible) -> void:
	if panel_main_instance:
		panel_main_instance.visible = visible

func _get_plugin_name() -> String:
	return "Audio"

func _get_plugin_icon() -> Texture2D:
	return ICON
