@tool
extends MenuBar
## Audio library manager: menu bar handler

signal stop_all_sounds

################################################################################

func _on_file_id_pressed(id):
	match id:
		0: # new library
			owner.new_library("Library", true)
		1: # clear libraries
			owner.get_node("ClearConfirmDialog").show()
		3: # import
			owner.import()
		4: # export
			owner.export()


func _on_libraries_id_pressed_libraries(id):
	match id:
		0: # stop all sounds
			emit_signal("stop_all_sounds")
