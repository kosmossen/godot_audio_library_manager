@tool
extends AcceptDialog
## Audio Library Manager: window base

@export var initial_focus : Control
@export var hide_ok := true

################################################################################

# GODOT

func _enter_tree():
	if hide_ok:
		get_ok_button().visible = false

func show() -> void:
	super()
	if initial_focus: 
		initial_focus.grab_focus()
	if hide_ok:
		get_ok_button().visible = false

# SIGNALS

## Close window
func _on_close_requested() -> void:
	hide()
