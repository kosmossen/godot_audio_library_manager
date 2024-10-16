
## 2. JSON Data

*Guide for plugin version 0.3*

### What is contained in the plugin data?

In the root of `data.json` there are two keys: `data` and `plugin`. `data` contains all the actual data used by the plugin while `plugin` simply identifies this JSON file as being used by this specific plugin (and thus should not be modified as otherwise the plugin may not accept the JSON anymore.)

The keys inside `data` are the libraries themselves, created in the interface by the user such as `Music` or `SFX`.

Inside these library keys are four keys: `config`, `files`, `aliases`, `fresh` and `id`. `config` contains configuration data for the library while `files` contains the discovered sound files in the library path + their individual configuration options, each key being the name of the sound file minus its extension.
`fresh` signifies whether the library has been initialized or not (not initialized = true) and `id` is the identifier of the library (should be same as the library's key). The `aliases` key contains the alias data for this library.

Under each sound file key is another two keys: `metadata` and `settings`. `metadata` contains information about the file, such as filename, filetype and file path. `settings` contains the configuration settings set in the interface by the user for this individual sound.

### Example JSON data

```
{
	"data": {
		"Music": {
			"aliases": {

			},
			"config": {
				"bus": "Music",
				"exclusive": false,
				"path": "res://examples/res/music"
			},
			"files": {
				"music_renegade": {
					"metadata": {
						"filename": "music_renegade",
						"filetype": "ogg",
						"path": "res://examples/res/music/music_renegade.ogg"
					},
					"settings": {
						"pitch": 1,
						"poly": 1,
						"volume": 0
					}
				}
			},
			"fresh": false,
			"id": "Music"
		},
		"SFX": {
			"aliases": {
				"random": {
					"settings": {
						"aliasname": "random",
						"soundnames": "sfx_click/sfx_hurt/sfx_sparkle"
					},
					"valid": true
				}
			},
			"config": {
				"bus": "SFX",
				"exclusive": false,
				"path": "res://examples/res/SFX"
			},
			"files": {
				"sfx_click": {
					"metadata": {
						"filename": "sfx_click",
						"filetype": "ogg",
						"path": "res://examples/res/SFX/sfx_click.ogg"
					},
					"settings": {
						"pitch": 1,
						"poly": 1,
						"volume": 0
					}
				},
				"sfx_hurt": {
					"metadata": {
						"filename": "sfx_hurt",
						"filetype": "ogg",
						"path": "res://examples/res/SFX/sfx_hurt.ogg"
					},
					"settings": {
						"pitch": 1,
						"poly": 1,
						"volume": 0
					}
				},
				"sfx_sparkle": {
					"metadata": {
						"filename": "sfx_sparkle",
						"filetype": "ogg",
						"path": "res://examples/res/SFX/sfx_sparkle.ogg"
					},
					"settings": {
						"pitch": 1,
						"poly": 1,
						"volume": 0
					}
				}
			},
			"fresh": false,
			"id": "SFX"
		}
	},
	"plugin": "godot_audio_library_manager"
}
```

Previous: ![Getting Started](1_getting_started.md)
