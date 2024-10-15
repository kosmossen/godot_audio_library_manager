@tool
extends ItemList

@export var target_tabcontainer : TabContainer
@export var index_offset : int = 1
@export_subgroup("Icons")

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		target_tabcontainer.current_tab = 0
		item_selected.connect(_selected)

func _exit_tree() -> void:
	if item_selected.is_connected(_selected):
		item_selected.disconnect(_selected)

func _selected(index:int) -> void:
	if target_tabcontainer:
		target_tabcontainer.current_tab = index+index_offset

func select_null() -> void:
	if target_tabcontainer:
		target_tabcontainer.current_tab = 0
	deselect_all()
	#emit_signal("item_selected", 0)

func select_last_id() -> void:
	select(get_item_count()-1)
	emit_signal("item_selected", get_item_count()-1)

# SIGNALS

func _on_panel_base_library_list_updated() -> void:
	# remove all items
	clear()
	#
	var _main_panel = get_owner()
	var _libraries = _main_panel.panel_get_children(_main_panel.child_parent_control[0])
	# add item for each library
	var _index = 0
	for i in _libraries:
		add_item(i.id)
		match i.status.status_type:
			AudioLibraryStatus.STATUS.OK:
				set_item_custom_fg_color(_index, Color.WHITE)
			AudioLibraryStatus.STATUS.WARN:
				set_item_custom_fg_color(_index, Color.ORANGE)
			AudioLibraryStatus.STATUS.CRIT:
				set_item_custom_fg_color(_index, Color.RED)
			AudioLibraryStatus.STATUS.NEUTRAL:
				set_item_custom_fg_color(_index, Color.LIGHT_GRAY)
		_index += 1
