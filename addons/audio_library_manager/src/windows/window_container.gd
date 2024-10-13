@tool
extends "res://addons/audio_library_manager/src/windows/window_base.gd"
## Container window

var node_original_parent : Control
var node_original_visible : bool = false

func borrow(node:Control, custom_title:String="") -> void:
	# borrow node from its original parent
	node_original_parent = node.get_parent()
	node_original_visible = node.visible
	if not node.visible:
		node.visible = true
	node_original_parent.remove_child(node)
	$CenterContainer.add_child(node)
	
	if custom_title: title = custom_title
	
func return_node() -> void:
	# return child to itsoriginal parent
	var child = $CenterContainer.get_children()[0]
	child.visible = node_original_visible
	$CenterContainer.remove_child(child)
	node_original_parent.add_child(child)
	
func _on_close_requested() -> void:
	return_node()
	#
	super()

func _on_confirmed() -> void:
	return_node()
