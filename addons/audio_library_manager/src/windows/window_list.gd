@tool
extends "res://addons/audio_library_manager/src/windows/window_base.gd"
## Audio Library Manager: list window

signal text_changed
signal accept_pressed(selected_items:Array[String])

@export var list_strings : Array[String]
@export var allow_multiple_select: bool = false:
	set(value):
		var _itemlist: Control = get_node_or_null("Panel/MarginContainer/VBoxContainer/ItemList")
		if _itemlist:
			if value:
				_itemlist.select_mode = ItemList.SELECT_MULTI
			else:
				_itemlist.select_mode = ItemList.SELECT_SINGLE
		allow_multiple_select = value

################################################################################

# GODOT

func _enter_tree() -> void:
	_allow_accept(false)

func _input(event):
	if visible:
		# crusty way of doing an accept shortcut, but the godot shortcut didn't work. might retry later
		if event is InputEventKey:
			if event.keycode == KEY_ENTER and not $Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled:
				_on_accept_button_up()

# PRIMARY

func reload():
	var _itemlist = $Panel/MarginContainer/VBoxContainer/ItemList
	_itemlist.clear()
	for i in list_strings:
		_itemlist.add_item(i)

func _allow_accept(allow:bool):
	if allow:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled = false
	else:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer/Accept.disabled = true

func show():
	super()
	reload()

# SIGNALS

## Accept pressed
func _on_accept_button_up():
	var _itemlist = $Panel/MarginContainer/VBoxContainer/ItemList
	var _out: Array[String] = []
	for i in _itemlist.get_selected_items():
		_out.append(_itemlist.get_item_text(i))
	emit_signal("accept_pressed", _out)
	hide()

## Cancel pressed
func _on_cancel_button_up():
	hide()

## Item selected on list
func _on_item_list_item_selected(index: int) -> void:
	_allow_accept(true)

## Item selected on list (multi)
func _on_item_list_multi_selected(index: int, selected: bool) -> void:
	_allow_accept(true)
