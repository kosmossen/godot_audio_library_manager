### - v0.3.0

##### FIXED

* Fixed bug causing dictionary keys of libraries not being set properly in data, leading to odd behaviour.

### - v0.3.0

##### Features
* New 'Alias' feature
	* Found under a new tab in every library
	* Allows for assigning any amount of sounds to an arbitary name (alias) which can then be called using standard sound playing functions. If there are multiple sounds assigned to an alias, a random one will be played
	* If there exists a sound and an alias under the same name, the alias will be played instead of the sound.
##### Interface
* Changed library top button appearance to monochrome and add icons
* Removed title labels from libraries
##### Other
* Audio library data now stored in the Godot project root under filename "audio_library.gdal"
* CHANGELOG.md for keeping track of changelog within project files
* Updated documentation to match new version
