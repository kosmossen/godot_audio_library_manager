@tool
extends "res://addons/audio_library_manager/src/windows/window_base.gd"
## Audio Library Manager: rename window

signal text_changed
signal accept_pressed(entered_name:String)

@export var taken_names : Array[String]
@export var max_length : int = 64

################################################################################

# GODOT

func _enter_tree():
	_allow_accept(false, "No name entered.")

func _input(event):
	if visible:
		# crusty way of doing an accept shortcut, but the godot shortcut didn't work. might retry later
		if event is InputEventKey:
			if event.keycode == KEY_ENTER and not $Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled:
				_on_accept_button_up()

# PRIMARY

func reload():
	var re = RegEx.new()
	re.compile("\\s*")
	var _text = $Panel/MarginContainer/VBoxContainer/LineEdit.text
	# make sure length is ok
	if _text.length() > max_length:
		_allow_accept(false, "Name length exceeds maximum length (%s)." % max_length)
	# check for taken names
	elif _text.to_lower() in taken_names:
		_allow_accept(false, "Name is taken.")
	# nothing entered
	elif _text == "" or _text.length() == re.search(_text).get_string(0).length():
		_allow_accept(false, "No name entered.")
	else:
		_allow_accept(true)

func _allow_accept(allow:bool, msg:String=""):
	if allow:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled = false
		$Panel/MarginContainer/VBoxContainer/StatusBG/MarginContainer/Status.text = "Name is available."
	else:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled = true
		$Panel/MarginContainer/VBoxContainer/StatusBG/MarginContainer/Status.text = msg

# SIGNALS

## LineEdit changed
func _on_line_edit_text_changed(new_text):
	emit_signal("text_changed")
	reload()

## Accept pressed
func _on_accept_button_up():
	emit_signal("accept_pressed", $Panel/MarginContainer/VBoxContainer/LineEdit.text)
	hide()
	$Panel/MarginContainer/VBoxContainer/LineEdit.clear()

## Cancel pressed
func _on_cancel_button_up():
	hide()
	$Panel/MarginContainer/VBoxContainer/LineEdit.clear()
