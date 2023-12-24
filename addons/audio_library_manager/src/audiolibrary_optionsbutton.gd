@tool
extends OptionButton
## Audio library manager: extended options button

func set_options(options:Array, retain_selection:bool=false, select_string:String="") -> void:
	if retain_selection and not select_string:
		select_string = get_selected_string()
	clear()
	var _index := 0
	for i in options:
		add_item(i)
		if select_string:
			if select_string == i:
				select(_index)
		_index += 1
	
func get_selected_string() -> String:
	return get_item_text(get_selected_id())
