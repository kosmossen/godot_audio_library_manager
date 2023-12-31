@icon("res://addons/audio_library_manager/res/icon.svg")
class_name AudioLibrary extends Node
## Audio Library Manager
##
## AudioLibrary class for playing, stopping and getting sounds from the audio library.

signal library_built

enum MODE {
	STATIC,
	DYNAMIC
}

## Audio objects
const OBJ_AUDIO_2D = preload("res://addons/audio_library_manager/src/objects/obj_audiolibrary_2d_audio.tscn")
const OBJ_AUDIO_3D = preload("res://addons/audio_library_manager/src/objects/obj_audiolibrary_3d_audio.tscn")
## Maximum amount of simultaneous AudioStreamPlayers in dynamic mode
const MAX_DYNAMIC_CHANNELS : int = 32

var plugin
## Library mode - static or dynamic
var library_mode : MODE = MODE.STATIC
## Table of references to generated (global) audiostreamplayers for quicker access (static library only)
var _lookup = {}
## Loaded data at library build
var _loaded_data = {}
## Library active
var active := false

################################################################################

# GODOT

func _enter_tree():
	name = "AudioLibrary"
	# initial library building
	match library_mode:
		MODE.STATIC:
			var _library_build = _build_library()
			if active: 
				print("Audio library built successfully with %s libraries and %s sounds total." % [_library_build[0], _library_build[1]])
				emit_signal("library_built")
		MODE.DYNAMIC:
			var _library_build = _build_library_dynamic()
			if active: 
				print("Dynamic audio library initialized with %s libraries and %s sounds total." % [_library_build[0], _library_build[1]])
				emit_signal("library_built")

# STATIC

## Create a new instance of AudioLibrary as child of "parent" and return it.
static func initialize(parent:Node, deferred:bool=false) -> Node:
	var _new = new()
	if deferred:
		parent.add_child.call_deferred(_new)
	else:
		parent.add_child(_new)
	return _new

# INTERNAL

## Static library - more memory intensive, less CPU usage and latency
func _build_library():
	library_mode = MODE.STATIC
	# nuke all existing children
	for i in get_children():
		i.queue_free()
	# clear lookup dictionary
	_lookup.clear()
	# load audio library data from file
	var _data = AudioLibraryData.data_load(false)
	if not _data is Dictionary:
		push_error("Library building failed, no data found. Library functions disabled.")
		active = false
		return []
	elif not _data:
		push_warning("Library building failed, data is empty. Library functions disabled. Try creating some libraries in the 'Audio' tab at the top of the editor!")
		active = false
		return []
	_loaded_data = _data
	# build the libraries and create lookup dictionary
	var _n_library := 0
	var _n_sound := 0
	for i in _data:
		var _node_library = Node.new()
		if not i:
			push_error("Library building failed, data contains empty keys. Library functions disabled.")
			active = false
			return []
		_node_library.name = i
		add_child(_node_library)
		#_node_library.set_meta("exclusive", _data[i]["config"]["exclusive"])
		_node_library.set_meta("config", _data[i]["config"])
		_lookup[i] = {}
		_n_library += 1
		# add ASPs to library
		for j in _data[i]["files"]:
			var _node_asp = AudioStreamPlayer.new()
			if not j:
				push_error("Library building failed, data contains empty keys. Library functions disabled.")
				active = false
				return []
			_node_asp.name = j
			_node_library.add_child(_node_asp)
			data_to_audiostreamplayer(_node_asp, i, j)
			# add library name for ease of library source recognition from asp
			_node_asp.set_meta("library", i)
			_lookup[i][j] = _node_asp
			_n_sound += 1
	active = true
	return [_n_library, _n_sound]

## Dynamic library - less memory intensive, more CPU usage and latency
## TODO: Dynamic mode is currently unfinished and non-functional.
func _build_library_dynamic():
	library_mode = MODE.DYNAMIC
	# nuke all existing children
	for i in get_children():
		i.queue_free()
	# clear lookup dictionary
	_lookup.clear()
	# load audio library data from file
	var _data = AudioLibraryData.data_load(false)
	if not _data is Dictionary:
		push_warning("Library building failed, no data found. Library functions disabled.")
		active = false
		return []
	elif not _data:
		push_warning("Library building failed, data is empty. Library functions disabled. Create a library in the 'Audio' tab at the top of the editor!")
		active = false
		return []
	_loaded_data = _data
	#
	var _n_library := 0
	var _n_sound := 0
	for i in _loaded_data:
		_n_library += 1
		for j in _data[i]["files"]:
			_n_sound += 1
	return [_n_library, _n_sound]

func _data_to_asp(asp:Node, data_sound:Dictionary, data_library:Dictionary):
	asp.stream = load(data_sound["metadata"]["path"])
	asp.pitch_scale = data_sound["settings"]["pitch"]
	asp.volume_db = data_sound["settings"]["volume"]
	asp.max_polyphony = data_sound["settings"]["poly"]
	asp.bus = data_library["config"]["bus"]

func _clone_asp_data(source_asp:Node, target_asp:Node):
	target_asp.stream = source_asp.stream
	target_asp.pitch_scale = source_asp.pitch_scale
	target_asp.volume_db = source_asp.volume_db
	target_asp.bus = source_asp.bus
	target_asp.max_polyphony = source_asp.max_polyphony

func _get_asp(library_name:String, sound_name:String, strip_extension:bool=true): 
	if strip_extension:
		sound_name = sound_name.replace(".%s" % sound_name.get_extension(), "")
	if library_name in _lookup:
		if sound_name in _lookup[library_name]:
			return _lookup[library_name][sound_name]
		else:
			return false
	else:
		return false

func _erase_invalid_entries() -> void:
	for i in _loaded_data:
		for j in _loaded_data[i]["files"]:
			if not FileAccess.file_exists(_loaded_data[i]["files"][j]["metadata"]["path"]):
				_loaded_data[i]["files"].erase(j)

# PRIMARY

## Get the data of a chosen sound from an audio library.
## Returns a dictionary containing the sound's data, such as its filename, path, library volume/pitch, etc.
## Example: var data = get_data("SFX", "sfx_dash")
func get_data(library_name:String, sound_name:String="", strip_extension:bool=true) -> Dictionary:
	var _data = _loaded_data
	if strip_extension:
		sound_name = sound_name.replace(".%s" % sound_name.get_extension(), "")
	if library_name in _data:
		if not sound_name:
			return _data[library_name]
		elif sound_name in _data[library_name]["files"]:
			return _data[library_name]["files"][sound_name]
		else:
			push_error("Unable to get data from audio library: Sound '%s' not found in library '%s'." % [sound_name, library_name])
			return {}
	else:
		push_error("Unable to get data from audio library: Library '%s' not found." % library_name)
		return {}

## Feed an AudioStreamPlayer the data of a chosen sound from audio library data.
## Example: data_to_audiostreamplayer(audiostreamplayer_node, "SFX", "sfx_dash")
func data_to_audiostreamplayer(asp:Node, library_name:String, sound_name:String) -> Error:
	var _data_sound = get_data(library_name, sound_name)
	var _data_library = get_data(library_name)
	if _data_sound and _data_library:
		_data_to_asp(asp, _data_sound, _data_library)
		return OK
	else:
		return ERR_DATABASE_CANT_READ

## Feed an AudioStreamPlayer the data from a library AudioStreamPlayer (STATIC MODE ONLY)
## Example: asp_to_audiostreamplayer(audiostreamplayer_node, "SFX", "sfx_dash")
func asp_to_audiostreamplayer(asp:Node, library_name:String, sound_name:String) -> Error:
	if library_mode == MODE.DYNAMIC:
		var _source_asp = _get_asp(library_name, sound_name)
		if not _source_asp:
			push_error("Unable to copy data to AudioStreamPlayer, sound not found in lookup")
			return ERR_FILE_NOT_FOUND
		_clone_asp_data(_source_asp, asp)
		return OK
	push_error("Unable to copy data to AudioStreamPlayer, AudioLibrary inactive or in dynamic mode.")
	return ERR_UNAVAILABLE
	
## Get all currently playing global AudioStreamPlayers in a library and return their references in an array.
## Example: get_playing_audiostreamplayers("SFX")
func get_playing_audiostreamplayers(library_name:String) -> Array:
	if active:
		var _playing = []
		for i in get_children():
			if i.name == library_name:
				for j in i.get_children():
					if j.playing:
						_playing.append(j)
		return _playing
	return []

# PLAYBACK

## Play a global sound from an audio library.
## Example: play_sound("SFX", "sfx_dash")
func play_sound(library_name:String, sound_name:String) -> Error:
	if active:
		var _asp = _get_asp(library_name, sound_name)
		if _asp:
			if _asp.get_parent().get_meta("config")["exclusive"]:
				stop_all_sounds(library_name)
			_asp.play()
			return OK
		else:
			push_error("Unable to play sound, sound '%s' not found in library '%s'" % [sound_name, library_name])
			return ERR_FILE_NOT_FOUND
	push_warning("Unable to play sound '%s' in library '%s', AudioLibrary class has not yet initialized!" % [sound_name, library_name])
	return ERR_UNAVAILABLE
	
## Stop a global sound being played from an audio library.
## Example: stop_sound("SFX", "sfx_dash")
func stop_sound(library_name:String, sound_name:String) -> Error:
	if library_name in _lookup:
		if sound_name in _lookup[library_name]:
			_lookup[library_name][sound_name].stop()
			return OK
		else:
			return ERR_FILE_NOT_FOUND
	else:
		return ERR_FILE_NOT_FOUND
	
## Stop all global AND local sounds being played from the audio library.
## If a library name is specified, only stops sounds in specific library.
## Example: stop_all_sounds()
func stop_all_sounds(library_name:String="") -> Error:
	for i in get_tree().get_nodes_in_group("AudioLibraryLocalPlayer"):
		if library_name:
			if i.get_meta("library") == library_name:
				i.queue_free()
		else:
			i.queue_free()
	#
	if library_name:
		for i in _lookup[library_name]:
			_lookup[library_name][i].stop()
	else:
		for i in _lookup:
			for j in i:
				j.stop()
	return OK

## Instantiate an AudioStreamPlayer2D parented to "world" Node, following a "target" Node2D's position playing sound from an audio library.
## The AudioStreamPlayer2D will free itself when it is done playing the sound.
## Example: play_2d_sound(player_node, "SFX", "sfx_dash", {"attenuation":2.0})
## Returns either the instantiated AudioStreamPlayer2D or an Error.
func play_2d_sound(world:Node, target:Node2D, library_name:String, sound_name:String, extra_variables:Dictionary={}) -> Variant:
	if active:
		if _loaded_data[library_name]["config"]["exclusive"]:
			stop_all_sounds(library_name)
		var _asp = OBJ_AUDIO_2D.instantiate()
		if not world:
			push_error("Unable to play 2D sound, given world node is invalid/does not exist")
			return ERR_DOES_NOT_EXIST
		if not target:
			push_error("Unable to play 2D sound, given target node is invalid/does not exist")
			return ERR_DOES_NOT_EXIST
		world.add_child(_asp)
		_asp.global_position = target.global_position
		_asp.target = target
		var _source_asp = _get_asp(library_name, sound_name)
		if not _source_asp:
			push_error("Unable to play 2D sound, sound '%s' not found in library '%s'" % [sound_name, library_name])
			return ERR_FILE_NOT_FOUND
		_clone_asp_data(_source_asp, _asp)
		for i in extra_variables:
			if i in _asp:
				_asp.set(i, extra_variables[i])
		# add library name for ease of library source recognition
		_asp.set_meta("library", library_name)
		_asp.play()
		return _asp
	push_warning("Unable to play 2D sound '%s' in library '%s', AudioLibrary class has not yet initialized!" % [sound_name, library_name])
	return ERR_UNAVAILABLE
	
## Instantiate an AudioStreamPlayer3D parented to "world" Node, following a "target" Node3D's position playing sound from an audio library.
## The AudioStreamPlayer3D will free itself when it is done playing the sound.
## Example: play_3d_sound(player_node, "SFX", "sfx_dash", {"attenuation":2.0})
## Returns either the instantiated AudioStreamPlayer3D or an Error.
func play_3d_sound(world:Node, target:Node3D, library_name:String, sound_name:String, extra_variables:Dictionary={}) -> Variant:
	if active:
		if _loaded_data[library_name]["config"]["exclusive"]:
			stop_all_sounds(library_name)
		var _asp = OBJ_AUDIO_3D.instantiate()
		if not world:
			push_error("Unable to play 3D sound, given world node is invalid/does not exist")
			return ERR_DOES_NOT_EXIST
		if not target:
			push_error("Unable to play 3D sound, given target node is invalid/does not exist")
			return ERR_DOES_NOT_EXIST
		world.add_child(_asp)
		_asp.global_position = target.global_position
		_asp.target = target
		var _source_asp = _get_asp(library_name, sound_name)
		if not _source_asp:
			push_error("Unable to play 3D sound, sound '%s' not found in library '%s'" % [sound_name, library_name])
			return ERR_FILE_NOT_FOUND
		_clone_asp_data(_source_asp, _asp)
		for i in extra_variables:
			if i in _asp:
				_asp.set(i, extra_variables[i])
		# add library name for ease of library source recognition
		_asp.set_meta("library", library_name)
		_asp.play()
		return _asp
	push_warning("Unable to play 3D sound '%s' in library '%s', AudioLibrary class has not yet initialized!" % [sound_name, library_name])
	return ERR_UNAVAILABLE
