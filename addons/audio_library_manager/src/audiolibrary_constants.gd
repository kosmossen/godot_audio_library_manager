extends Resource
## Audio library manager constants

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
	"files": {}
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
		"max" : 100,
		"scale" : 1.0,
	}
}
