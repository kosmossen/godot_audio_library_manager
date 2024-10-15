extends Resource
## Audio library manager constants

const INIT_MESSAGE : String = "Audio Library Manager initialized."

# Preload resources

const RES_NULL = preload("res://addons/audio_library_manager/res/null.svg")
const RES_OK = preload("res://addons/audio_library_manager/res/ok.svg")
const RES_WARN = preload("res://addons/audio_library_manager/res/warn.svg")
const RES_ERR = preload("res://addons/audio_library_manager/res/error.svg")

# Formats

const VALID_FORMATS : Array[String] = [
	"ogg",
	"mp3",
	"wav",
]

# Templates

## Library data template
const TEMPLATE_LIBRARY : Dictionary = {
	"id" : "",
	"fresh": false,
	"config": {
		"path" : "",
		"bus" : "",
		"exclusive" : false,
	},
	"files": {},
	"aliases": {}
}

## Entry data template
const TEMPLATE_ENTRY : Dictionary = {
	"metadata": {
		"path" : "",
		"filename" : "",
		"filetype" : "",
	},
	"settings": {
		"volume" : 0.0,
		"pitch" : 1.0,
		"poly" : 1
	}
}

## Alias entry data template
const TEMPLATE_ALIAS_ENTRY : Dictionary = {
	"valid": true,
	"settings": {
		"aliasname" : "",
		"soundnames" : "",
	}
}

## Sound settings template
const TEMPLATE_SOUND_SETTINGS := {
	"volume" : {
		"control_var" : "ui_volume",
		"default" : 0.0,
		"min" : -100.0,
		"max" : 24.0,
		"scale" : 1.0,
	},
	"pitch" : {
		"control_var" : "ui_pitch",
		"default" : 1.0,
		"min" : 0.01,
		"max" : 4.0,
		"scale" : 100.0,
	},
	"poly" : {
		"control_var" : "ui_poly",
		"default" : 1,
		"min" : 1,
		"max" : 1024,
		"scale" : 1.0,
	}
}
